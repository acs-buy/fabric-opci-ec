-- pr_valider_brouillon_corps : 2 refus
-- pr_valider_brouillon : le corps d'origine, renomme
-- pr_valider_brouillon : le corps d'origine, renomme
-- --- 6 : pr_valider_brouillon, refaite -------------------------------
CREATE   PROCEDURE dbo.pr_valider_brouillon_corps
    @entite       VARCHAR (20),
    @arrete       VARCHAR (20),
    @feuille_cote VARCHAR (30),
    @question_id  INT,
    @valide_par   NVARCHAR (200)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    -- 51317 (15/11/2026) : action 24, viseur compris. Juge sur @par, celui qui clique, par sa connexion, avant toute ecriture (la session SQL d'une
    -- Data function est celle du proprietaire). Un semis ecrit sans cette garde.
    IF ISNULL(TRY_CAST(SESSION_CONTEXT(N'semis') AS INT), 0) <> 1
       AND EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @entite) AND dbo.fn_membre_equipe(@entite, @arrete, NULLIF(LTRIM(RTRIM(@valide_par)), N''), CAST(SYSUTCDATETIME() AS DATE)) = 0
        THROW 51317, N'Action refusée : seule l''équipe du dossier peut valider les OD d''une question de ce dossier.', 1;

    -- Le perimetre est la QUESTION, non la feuille entiere : un lot est
    -- par question (fk_lot_question), et valider une question ne doit
    -- pas emporter le brouillon des autres.
    IF NOT EXISTS (SELECT 1 FROM dbo.ecriture_brouillon
                   WHERE entite = @entite AND arrete = @arrete
                     AND feuille_cote = @feuille_cote
                     AND question_id = @question_id)
        THROW 50031,
            N'Validation refusée : la question choisie n''a aucune ligne de brouillon. Saisir ses lignes, ou choisir une autre question.', 1;

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
            N'Validation refusée : ' + CAST(@a_completer AS NVARCHAR (10)) + N' ligne(s) du brouillon sans débit ni crédit. Saisir leur montant ou les retirer.';
        BEGIN SET @m0 = REPLACE(@m0, N'%', N'%%'); THROW 50046, @m0, 1; END
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        -- question_id est pose sur le lot : ck_lot_source_par_famille
        -- l'exige pour la famille DECIDEE, et son absence faisait echouer
        -- cette procedure.
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
            N'Validation refusée, le brouillon est conservé. Motif : ' + @motif;
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50030, @m, 1; END
    END CATCH;
END;

GO

