
-- ACTIVER OU RETIRER UN CYCLE ENTIER. A l'activation, toutes ses questions eligibles entrent ; au
-- retrait, toutes sortent, avec les memes refus que pour une question : motif obligatoire, aucune
-- question repondue, et pas de retrait d'un cycle qui a des comptes en balance.
CREATE   PROCEDURE dbo.pr_activer_cycle
    @entite  VARCHAR (20),
    @arrete  VARCHAR (20),
    @cycle   VARCHAR (10),
    @actif   BIT,
    @motif   NVARCHAR (400) = NULL,
    @par     NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @id INT = (SELECT id FROM dbo.programme_travail WHERE entite = @entite AND arrete = @arrete);
    IF @id IS NULL
        THROW 50311, N'Aucun programme n''est choisi pour cet arrêté ; choisir un type d''abord.', 1;
    IF dbo.fn_dossier_verrouille(@entite, @arrete) = 1
        THROW 50303, N'Le dossier de cet arrêté est visé et verrouillé ; le déverrouiller avant de modifier le programme.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_cycle WHERE code = @cycle)
        THROW 50320, N'Le cycle désigné n''existe pas.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.v_programme_selection WHERE programme_id = @id AND cycle = @cycle)
        THROW 50321, N'Ce cycle n''a aucune question applicable à ce type d''arrêté.', 1;
    SET @motif = NULLIF(LTRIM(RTRIM(@motif)), N'');
    DECLARE @m NVARCHAR (2000), @n INT;
    IF @actif = 0
    BEGIN
        IF @motif IS NULL
            THROW 50313, N'Le motif du retrait est obligatoire : il reste au journal du programme.', 1;
        SET @n = (SELECT COUNT(*) FROM dbo.v_programme_selection WHERE programme_id = @id AND cycle = @cycle AND actif = 1 AND repondue = 1);
        IF @n > 0
        BEGIN
            SET @m = N'Le cycle ' + @cycle + N' compte ' + CAST(@n AS NVARCHAR (10))
                   + N' question(s) répondue(s) : il reste au programme, et ses réponses au dossier.';
            THROW 50322, @m, 1;
        END;
        SET @n = (SELECT COUNT(*) FROM dbo.fn_comptes_du_cycle(@entite, @arrete, @cycle));
        IF @n > 0
        BEGIN
            SET @m = N'Le cycle ' + @cycle + N' porte ' + CAST(@n AS NVARCHAR (10)) + N' compte(s) en balance : '
                   + (SELECT STRING_AGG(compte, ', ') WITHIN GROUP (ORDER BY compte)
                      FROM (SELECT TOP 10 compte FROM dbo.fn_comptes_du_cycle(@entite, @arrete, @cycle) ORDER BY compte) t)
                   + CASE WHEN @n > 10 THEN N' et ' + CAST(@n - 10 AS NVARCHAR (10)) + N' autre(s)' ELSE N'' END
                   + N'. Un compte de la balance reste couvert par au moins une question.';
            THROW 50323, @m, 1;
        END;
    END;

    DECLARE @touchees TABLE (question_id INT PRIMARY KEY);
    BEGIN TRY
    BEGIN TRANSACTION;
    IF @actif = 1
    BEGIN
        INSERT INTO @touchees
        SELECT q.id FROM dbo.v_programme_selection s JOIN dbo.ref_question q ON q.reference = s.reference
        WHERE s.programme_id = @id AND s.cycle = @cycle AND s.actif = 0;
        UPDATE pq SET actif = 1, modifie_par = @par, modifie_le = SYSUTCDATETIME()
        FROM dbo.programme_question pq JOIN @touchees t ON t.question_id = pq.question_id WHERE pq.programme_id = @id;
        INSERT INTO dbo.programme_question (programme_id, question_id, actif, origine, modifie_par)
        SELECT @id, t.question_id, 1, 'AJOUT', @par FROM @touchees t
        WHERE NOT EXISTS (SELECT 1 FROM dbo.programme_question pq WHERE pq.programme_id = @id AND pq.question_id = t.question_id);
    END
    ELSE
    BEGIN
        INSERT INTO @touchees
        SELECT pq.question_id FROM dbo.programme_question pq JOIN dbo.ref_question q ON q.id = pq.question_id
        WHERE pq.programme_id = @id AND q.cycle = @cycle AND pq.actif = 1 AND pq.origine IN ('TYPE', 'AJOUT');
        UPDATE pq SET actif = 0, modifie_par = @par, modifie_le = SYSUTCDATETIME()
        FROM dbo.programme_question pq JOIN @touchees t ON t.question_id = pq.question_id WHERE pq.programme_id = @id;
    END;
    INSERT INTO dbo.programme_journal (programme_id, question_id, geste, detail, par)
    SELECT @id, t.question_id, CASE WHEN @actif = 1 THEN 'AJOUT' ELSE 'RETRAIT' END,
           LEFT(N'cycle ' + @cycle + ISNULL(N' : ' + @motif, N''), 400), @par
    FROM @touchees t;
    EXEC dbo.pr_instancier_programme @id, @par;
    COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
    SET @n = (SELECT COUNT(*) FROM @touchees);
    SELECT @cycle AS cycle, @n AS questions,
           N'Cycle ' + @cycle + CASE WHEN @actif = 1 THEN N' activé : ' ELSE N' retiré : ' END
         + CAST(@n AS NVARCHAR (10)) + CASE WHEN @actif = 1 THEN N' question(s) entrée(s) au programme.'
                                            ELSE N' question(s) sortie(s) du programme.' END AS message;
END;

GO

