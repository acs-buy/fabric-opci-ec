
-- --- 6 : pr_valider_brouillon, refaite -------------------------------
CREATE   PROCEDURE dbo.pr_valider_brouillon
    @entite       VARCHAR (20),
    @arrete       VARCHAR (20),
    @feuille_cote VARCHAR (30),
    @question_id  INT,
    @valide_par   NVARCHAR (200)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- Le perimetre est la QUESTION, non la feuille entiere : un lot est
    -- par question depuis le script 56, et valider une question ne doit
    -- pas emporter le brouillon des autres.
    IF NOT EXISTS (SELECT 1 FROM dbo.ecriture_brouillon
                   WHERE entite = @entite AND arrete = @arrete
                     AND feuille_cote = @feuille_cote
                     AND question_id = @question_id)
        THROW 50031,
            N'Aucune ligne de brouillon pour cette question : rien a valider. Le perimetre de la validation est la question, non la feuille entiere.', 1;

    -- Une ligne restee a zero ne se valide pas. Le brouillon l'admet, la
    -- validation la refuse : une ligne s'ouvre vide et se remplit.
    DECLARE @a_completer INT =
        (SELECT COUNT(*) FROM dbo.ecriture_brouillon
         WHERE entite = @entite AND arrete = @arrete
           AND feuille_cote = @feuille_cote AND question_id = @question_id
           AND debit = 0 AND credit = 0);
    IF @a_completer > 0
    BEGIN
        DECLARE @m0 NVARCHAR (2000) =
            N'Validation refusee : ' + CAST(@a_completer AS NVARCHAR (10))
            + N' ligne(s) du brouillon n''ont ni debit ni credit. Une ligne '
            + N'peut rester vide pendant la saisie, jamais a la validation : '
            + N'renseigner son montant ou la retirer.';
        THROW 50046, @m0, 1;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        -- question_id est pose sur le lot : ck_lot_source_par_famille
        -- l'exige pour la famille DECIDEE, et son absence faisait echouer
        -- cette procedure depuis le script 56.
        INSERT INTO dbo.lot_ecritures
            (arrete, famille, portee, entite, feuille_cote, question_id,
             statut, cree_par)
        VALUES (@arrete, 'DECIDEE', 'ENTITE', @entite, @feuille_cote,
                @question_id, 'PROPOSE', @valide_par);
        DECLARE @lot INT = CAST(SCOPE_IDENTITY() AS INT);

        -- Les 10 colonnes du format passent au complet : le code tiers en
        -- compte auxiliaire, la reference en reference de piece, le libelle
        -- du compte repris du plan de comptes.
        INSERT INTO dbo.ecriture
            (lot_id, journal_code, journal_lib, ecriture_num, ecriture_date,
             compte_num, compte_lib, comp_aux_num, comp_aux_lib, piece_ref,
             ecriture_lib, debit, credit, famille)
        SELECT @lot, b.journal_code, N'OD de revision',
               CAST(@lot AS VARCHAR (20)),
               COALESCE(r.date_arrete, CONVERT(DATE, LEFT(@arrete, 10))),
               b.compte_num,
               COALESCE(c.libelle_complet, c.libelle, b.compte_num),
               b.code_tiers,
               e.denomination,
               b.reference,
               b.libelle, b.debit, b.credit, 'DECIDEE'
        FROM dbo.ecriture_brouillon b
        LEFT JOIN dbo.ref_compte c ON c.compte = b.compte_num
        LEFT JOIN dbo.ref_entite e ON e.code = b.code_tiers
        LEFT JOIN dbo.ref_arrete r ON r.entite = b.entite AND r.arrete = b.arrete
        WHERE b.entite = @entite AND b.arrete = @arrete
          AND b.feuille_cote = @feuille_cote
          AND b.question_id = @question_id;

        -- L'axe analytique suit, ligne par ligne. L'appariement se fait sur
        -- le compte et le libelle, qui identifient la ligne dans son lot.
        INSERT INTO dbo.ecriture_axe (ecriture_id, entite, code_actif)
        SELECT x.id, @entite, b.code_actif
        FROM dbo.ecriture_brouillon b
        JOIN dbo.ecriture x ON x.lot_id = @lot
                           AND x.compte_num = b.compte_num
                           AND x.ecriture_lib = b.libelle
        WHERE b.entite = @entite AND b.arrete = @arrete
          AND b.feuille_cote = @feuille_cote
          AND b.question_id = @question_id
          AND b.code_actif IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM dbo.ecriture_axe z
                          WHERE z.ecriture_id = x.id);

        DELETE FROM dbo.ecriture_brouillon
        WHERE entite = @entite AND arrete = @arrete
          AND feuille_cote = @feuille_cote
          AND question_id = @question_id;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        DECLARE @motif NVARCHAR (400) = LEFT(ERROR_MESSAGE(), 400);
        DECLARE @m NVARCHAR (2000) =
            N'Validation refusee, le brouillon est conserve tel quel. Motif rendu par la base : '
            + @motif;
        THROW 50030, @m, 1;
    END CATCH;
END;

GO

