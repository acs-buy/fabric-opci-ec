-- 206 : ouvrir le questionnaire de maintien d'un client, comme le 205 ouvre celui de l'acceptation.
--
-- MESURE LE 16/09/2026 : pr_ouvrir_maintien (script 102) exige une feuille de phase MAINTIEN deja
-- existante (refus 50068), et rien ne la cree : le jeu porte MTN-OMEGA-OPCI-2025, semee par
-- l'historique avec ses 36 questions. Le bouton « Ouvrir le maintien » de la maquette 71 doit donc
-- creer la feuille et ses questions avant d'appeler la procedure, meme geste que pour l'acceptation.
--
-- La feuille s'adosse a l'arrete conclu, qui existe au referentiel par construction : on ne maintient
-- une mission qu'apres un arrete. Cote MTN-<entite>-<annee de l'arrete conclu>, comme sur le jeu.

CREATE   PROCEDURE dbo.pr_ouvrir_questionnaire_maintien
    @entite         VARCHAR (20),
    @arrete_conclu  VARCHAR (20),
    @par            NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @entite AND est_client = 1)
        THROW 50281, N'Le maintien ne s''ouvre que sur un client du cabinet.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_arrete WHERE entite = @entite AND arrete = @arrete_conclu)
        THROW 50282, N'L''arrêté conclu désigné n''est pas au référentiel de ce client.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.arrete_mission WHERE entite = @entite AND arrete = @arrete_conclu)
        THROW 50283, N'Le maintien porte sur un arrêté ouvert et conclu ; celui-ci n''a pas été ouvert.', 1;

    DECLARE @cote VARCHAR (30) = 'MTN-' + @entite + '-' + LEFT(@arrete_conclu, 4);
    DECLARE @deja INT = (SELECT COUNT(*) FROM dbo.feuille_question WHERE cote = @cote);
    IF @deja > 0
    BEGIN
        SELECT @cote AS cote, @deja AS questions,
               N'Le maintien ' + LEFT(@arrete_conclu, 4) + N' de ' + @entite + N' est déjà ouvert, ' + CAST(@deja AS NVARCHAR (10)) + N' questions.' AS message;
        RETURN;
    END;

    BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM dbo.feuille_travail WHERE cote = @cote)
        INSERT INTO dbo.feuille_travail
            (cote, cycle, phase, arrete, entite, modele_code, origine, nom_fichier, chemin_coffre,
             empreinte_sha256, preparateur, prepare_le)
        VALUES
            (@cote, NULL, 'MAINTIEN', @arrete_conclu, @entite, NULL, 'HUMAINE',
             N'questionnaire_maintien_' + @entite + N'_' + LEFT(@arrete_conclu, 4) + N'.xlsx',
             N'/Coffre/' + @entite + N'/' + @arrete_conclu + N'/questionnaire_maintien.xlsx',
             CONVERT(CHAR (64), HASHBYTES('SHA2_256', CONVERT(NVARCHAR (100), @cote)), 2),
             @par, SYSUTCDATETIME());
    INSERT INTO dbo.feuille_question (cote, question_id)
    SELECT @cote, q.id FROM dbo.ref_question q
    WHERE q.phase = 'MAINTIEN' AND q.statut <> 'ECARTEE'
      AND NOT EXISTS (SELECT 1 FROM dbo.feuille_question fq WHERE fq.cote = @cote AND fq.question_id = q.id);
    SET @deja = @@ROWCOUNT;
    EXEC dbo.pr_ouvrir_maintien @entite, @arrete_conclu, @cote, @par;
    COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @cote AS cote, @deja AS questions,
           N'Questionnaire de maintien ' + LEFT(@arrete_conclu, 4) + N' ouvert : ' + CAST(@deja AS NVARCHAR (10))
         + N' questions à répondre, en ligne ou par classeur.' AS message;
END;

GO

