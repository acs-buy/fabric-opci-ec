
-- --- 3. ouvrir le questionnaire d'acceptation d'un client -------------------------------------
CREATE   PROCEDURE dbo.pr_ouvrir_questionnaire_acceptation
    @entite   VARCHAR (20),
    @arrete   VARCHAR (20)   = NULL,   -- l'arrete vise ; par defaut la prochaine cloture, planifiee
    @par      NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @entite AND est_client = 1)
        THROW 50231, N'L''acceptation ne s''ouvre que sur un client du cabinet. Une filiale n''a pas d''acceptation propre.', 1;

    DECLARE @cote VARCHAR (30) = 'ACC-' + @entite;
    DECLARE @deja INT = (SELECT COUNT(*) FROM dbo.feuille_question WHERE cote = @cote);
    IF @deja > 0
    BEGIN
        SELECT @cote AS cote, @deja AS questions,
               N'Le questionnaire d''acceptation de ' + @entite + N' est déjà ouvert, ' + CAST(@deja AS NVARCHAR (10)) + N' questions.' AS message;
        RETURN;
    END;

    BEGIN TRY
    BEGIN TRANSACTION;
    -- l'arrete de rattachement, planifie s'il ne l'est pas encore
    IF @arrete IS NULL
    BEGIN
        DECLARE @cl DATE = dbo.fn_prochaine_cloture(@entite, CAST(SYSUTCDATETIME() AS DATE));
        IF @cl IS NULL
            THROW 50232, N'La date de clôture du client n''est pas lisible ; renseignez-la (jj/mm) avant d''ouvrir l''acceptation.', 1;
        SET @arrete = CONVERT(VARCHAR (10), @cl, 23);
        IF NOT EXISTS (SELECT 1 FROM dbo.ref_arrete WHERE entite = @entite AND arrete = @arrete)
            EXEC dbo.pr_planifier_arrete @entite, @cl, @cl, 'ANNUEL', @par;
    END
    ELSE IF NOT EXISTS (SELECT 1 FROM dbo.ref_arrete WHERE entite = @entite AND arrete = @arrete)
        THROW 50233, N'L''arrêté désigné n''est pas au référentiel de ce client. Planifiez-le d''abord.', 1;

    -- la feuille, meme forme que ACC-OMEGA-OPCI sur le jeu
    DECLARE @nom NVARCHAR (400) = N'questionnaire_acceptation_' + @entite + N'.xlsx';
    IF NOT EXISTS (SELECT 1 FROM dbo.feuille_travail WHERE cote = @cote)
        INSERT INTO dbo.feuille_travail
            (cote, cycle, phase, arrete, entite, modele_code, origine, nom_fichier, chemin_coffre,
             empreinte_sha256, preparateur, prepare_le)
        VALUES
            (@cote, NULL, 'ACCEPT', @arrete, @entite, NULL, 'HUMAINE', @nom,
             N'/Coffre/' + @entite + N'/permanent/questionnaire_acceptation.xlsx',
             CONVERT(CHAR (64), HASHBYTES('SHA2_256', CONVERT(NVARCHAR (100), @cote)), 2),
             @par, SYSUTCDATETIME());

    -- les questions de la phase, toutes, comme le jeu en porte 110 sur ACC-OMEGA-OPCI
    INSERT INTO dbo.feuille_question (cote, question_id)
    SELECT @cote, q.id FROM dbo.ref_question q
    WHERE q.phase = 'ACCEPT' AND q.statut <> 'ECARTEE'
      AND NOT EXISTS (SELECT 1 FROM dbo.feuille_question fq WHERE fq.cote = @cote AND fq.question_id = q.id);
    SET @deja = @@ROWCOUNT;

    -- l'acceptation elle-meme, par la procedure qui existe
    EXEC dbo.pr_ouvrir_acceptation @entite, @cote, @par;
    COMMIT;
    END TRY
    BEGIN CATCH
        -- un refus ne laisse jamais de transaction condamnee au caller : on annule ici, puis on relance
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @cote AS cote, @deja AS questions,
           N'Questionnaire d''acceptation ouvert : ' + CAST(@deja AS NVARCHAR (10))
         + N' questions à répondre, en ligne ou par classeur.' AS message;
END;

GO

