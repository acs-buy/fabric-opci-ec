
CREATE   PROCEDURE dbo.pr_valider_od_libres
    @entite      VARCHAR (20),
    @arrete      VARCHAR (20),
    @valide_par  NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @cote VARCHAR (30) = 'ODL-' + LEFT(@entite, 15) + '-' + REPLACE(@arrete, '-', '');
    IF dbo.fn_dossier_verrouille(@entite, @arrete) = 1
        THROW 50303, N'Le dossier de cet arrêté est visé et verrouillé.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.ecriture_brouillon WHERE entite = @entite AND arrete = @arrete AND feuille_cote = @cote AND question_id IS NULL)
        THROW 50391, N'Aucune OD libre au brouillon : rien à valider.', 1;
    DECLARE @sd DECIMAL (19, 2), @sc DECIMAL (19, 2), @vides INT;
    SELECT @sd = SUM(debit), @sc = SUM(credit), @vides = SUM(CASE WHEN debit = 0 AND credit = 0 THEN 1 ELSE 0 END)
    FROM dbo.ecriture_brouillon WHERE entite = @entite AND arrete = @arrete AND feuille_cote = @cote AND question_id IS NULL;
    IF @vides > 0
        THROW 50392, N'Validation refusée : des lignes n''ont ni débit ni crédit. Les renseigner ou les retirer.', 1;
    IF @sd <> @sc
    BEGIN
        DECLARE @m NVARCHAR (400) = N'Validation refusée : les OD libres ne sont pas équilibrées, débit ' + FORMAT(@sd, 'N2', 'fr-FR') + N', crédit ' + FORMAT(@sc, 'N2', 'fr-FR') + N'.';
        THROW 50393, @m, 1;
    END;
    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO dbo.lot_ecritures (arrete, famille, portee, entite, feuille_cote, question_id, statut, cree_par)
        VALUES (@arrete, 'DECIDEE', 'ENTITE', @entite, @cote, NULL, 'PROPOSE', @valide_par);
        DECLARE @lot INT = CAST(SCOPE_IDENTITY() AS INT);
        INSERT INTO dbo.ecriture (lot_id, journal_code, journal_lib, ecriture_num, ecriture_date, compte_num, compte_lib,
                                  comp_aux_num, comp_aux_lib, piece_ref, ecriture_lib, debit, credit, famille)
        SELECT @lot, b.journal_code, N'OD de revision libres', CAST(@lot AS VARCHAR (20)),
               COALESCE(r.date_arrete, CONVERT(DATE, LEFT(@arrete, 10))), b.compte_num,
               COALESCE(c.libelle_complet, c.libelle, b.compte_num), b.code_tiers, e.denomination, b.reference,
               b.libelle, b.debit, b.credit, 'DECIDEE'
        FROM dbo.ecriture_brouillon b
        LEFT JOIN dbo.ref_compte c ON c.compte = b.compte_num
        LEFT JOIN dbo.ref_entite e ON e.code = b.code_tiers
        LEFT JOIN dbo.ref_arrete r ON r.entite = b.entite AND r.arrete = b.arrete
        WHERE b.entite = @entite AND b.arrete = @arrete AND b.feuille_cote = @cote AND b.question_id IS NULL;
        INSERT INTO dbo.ecriture_axe (ecriture_id, entite, code_actif)
        SELECT x.id, @entite, b.code_actif
        FROM dbo.ecriture_brouillon b
        JOIN dbo.ecriture x ON x.lot_id = @lot AND x.compte_num = b.compte_num AND x.ecriture_lib = b.libelle
        WHERE b.entite = @entite AND b.arrete = @arrete AND b.feuille_cote = @cote AND b.question_id IS NULL AND b.code_actif IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM dbo.ecriture_axe z WHERE z.ecriture_id = x.id);
        DELETE dbo.ecriture_brouillon WHERE entite = @entite AND arrete = @arrete AND feuille_cote = @cote AND question_id IS NULL;
        COMMIT TRANSACTION;
        SELECT @lot AS lot_id, N'Lot ' + CAST(@lot AS NVARCHAR (10)) + N' proposé : les OD libres attendent le visa du chef de mission.' AS message;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;

GO

