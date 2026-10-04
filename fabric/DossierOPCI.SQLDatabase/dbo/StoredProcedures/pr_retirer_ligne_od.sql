

-- RETIRER UNE LIGNE DU BROUILLON DES OD LIBRES, avec sa trace.
CREATE   PROCEDURE dbo.pr_retirer_ligne_od
    @entite   VARCHAR (20),
    @arrete   VARCHAR (20),
    @ligne_id INT,
    @par      NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF dbo.fn_dossier_verrouille(@entite, @arrete) = 1
        THROW 50404, N'Retrait refusé : le dossier de cet arrêté est visé et verrouillé.', 1;
    DECLARE @cote VARCHAR (30) = 'ODL-' + LEFT(@entite, 15) + '-' + REPLACE(@arrete, '-', '');
    IF NOT EXISTS (SELECT 1 FROM dbo.ecriture_brouillon WHERE id = @ligne_id AND entite = @entite AND arrete = @arrete
                   AND feuille_cote = @cote AND question_id IS NULL)
        THROW 50403, N'Retrait refusé : la ligne désignée n''est pas au brouillon des OD libres de cet arrêté.', 1;
    BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO dbo.od_retrait (entite, arrete, feuille_cote, brouillon_id, compte_num, libelle, debit, credit, piece_ref, code_actif,
                                saisi_par, saisi_le, motif, retire_par)
    SELECT entite, arrete, feuille_cote, id, compte_num, libelle, debit, credit, reference, code_actif, saisi_par, saisi_le, NULL, @par
    FROM dbo.ecriture_brouillon WHERE id = @ligne_id;
    DELETE dbo.ecriture_brouillon WHERE id = @ligne_id;
    COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
    DECLARE @sd DECIMAL (19, 2), @sc DECIMAL (19, 2);
    SELECT @sd = ISNULL(SUM(debit), 0), @sc = ISNULL(SUM(credit), 0) FROM dbo.ecriture_brouillon
     WHERE entite = @entite AND arrete = @arrete AND feuille_cote = @cote AND question_id IS NULL;
    SELECT @cote AS cote, @sd AS debit, @sc AS credit,
           N'Ligne retirée du brouillon des OD libres'
         + CASE WHEN @sd <> @sc THEN N'. Déséquilibre de ' + FORMAT(@sd - @sc, 'N2', 'fr-FR') + N' : la validation le refusera.' ELSE N', équilibrées.' END AS message;
END;

GO

