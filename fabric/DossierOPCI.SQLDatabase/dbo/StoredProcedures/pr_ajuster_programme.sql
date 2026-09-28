
-- AJUSTER LE PROGRAMME QUESTION PAR QUESTION. Le motif est obligatoire au retrait, et va au journal.
-- Trois refus au retrait : sans motif, question repondue, derniere question active d'un cycle qui a
-- des comptes en balance. Un ajout n'admet qu'une question eligible a l'arrete.
CREATE   PROCEDURE dbo.pr_ajuster_programme
    @entite     VARCHAR (20),
    @arrete     VARCHAR (20),
    @reference  VARCHAR (20),
    @actif      BIT,                 -- 1 ajoute, 0 retire
    @par        NVARCHAR (400),
    @motif      NVARCHAR (400) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @id INT = (SELECT id FROM dbo.programme_travail WHERE entite = @entite AND arrete = @arrete);
    IF @id IS NULL
        THROW 50311, N'Aucun programme n''est choisi pour cet arrêté ; choisir un type d''abord.', 1;
    IF dbo.fn_dossier_verrouille(@entite, @arrete) = 1
        THROW 50303, N'Le dossier de cet arrêté est visé et verrouillé ; le déverrouiller avant de modifier le programme.', 1;
    DECLARE @qid INT, @cycle VARCHAR (10);
    SELECT @qid = id, @cycle = cycle FROM dbo.ref_question WHERE reference = @reference AND statut <> 'ECARTEE';
    IF @qid IS NULL OR @cycle IS NULL
        THROW 50312, N'La question désignée n''est pas une question de cycle du référentiel.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.v_programme_selection WHERE programme_id = @id AND reference = @reference)
        THROW 50316, N'Cette question ne s''applique pas à ce type d''arrêté : elle n''entre pas au programme.', 1;
    SET @motif = NULLIF(LTRIM(RTRIM(@motif)), N'');
    DECLARE @m NVARCHAR (2000);
    IF @actif = 0
    BEGIN
        IF @motif IS NULL
            THROW 50313, N'Le motif du retrait est obligatoire : il reste au journal du programme.', 1;
        IF EXISTS (SELECT 1 FROM dbo.v_programme_selection WHERE programme_id = @id AND reference = @reference AND repondue = 1)
        BEGIN
            SET @m = N'La question ' + @reference + N' porte une réponse : elle reste au programme, et sa réponse au dossier.';
            THROW 50314, @m, 1;
        END;
        IF NOT EXISTS (SELECT 1 FROM dbo.v_programme_selection
                       WHERE programme_id = @id AND cycle = @cycle AND actif = 1 AND reference <> @reference)
           AND EXISTS (SELECT 1 FROM dbo.fn_comptes_du_cycle(@entite, @arrete, @cycle))
        BEGIN
            DECLARE @n INT = (SELECT COUNT(*) FROM dbo.fn_comptes_du_cycle(@entite, @arrete, @cycle));
            SET @m = N'La question ' + @reference + N' est la dernière active du cycle ' + @cycle + N', qui porte '
                   + CAST(@n AS NVARCHAR (10)) + N' compte(s) en balance : '
                   + (SELECT STRING_AGG(compte, ', ') WITHIN GROUP (ORDER BY compte)
                      FROM (SELECT TOP 10 compte FROM dbo.fn_comptes_du_cycle(@entite, @arrete, @cycle) ORDER BY compte) t)
                   + CASE WHEN @n > 10 THEN N' et ' + CAST(@n - 10 AS NVARCHAR (10)) + N' autre(s)' ELSE N'' END
                   + N'. Un compte de la balance reste couvert par au moins une question.';
            THROW 50315, @m, 1;
        END;
    END;

    BEGIN TRY
    BEGIN TRANSACTION;
    IF EXISTS (SELECT 1 FROM dbo.programme_question WHERE programme_id = @id AND question_id = @qid)
        UPDATE dbo.programme_question SET actif = @actif, modifie_par = @par, modifie_le = SYSUTCDATETIME()
        WHERE programme_id = @id AND question_id = @qid;
    ELSE
        INSERT INTO dbo.programme_question (programme_id, question_id, actif, origine, modifie_par)
        VALUES (@id, @qid, @actif, 'AJOUT', @par);
    INSERT INTO dbo.programme_journal (programme_id, question_id, geste, detail, par)
    VALUES (@id, @qid, CASE WHEN @actif = 1 THEN 'AJOUT' ELSE 'RETRAIT' END,
            LEFT(@reference + ISNULL(N' : ' + @motif, N''), 400), @par);
    EXEC dbo.pr_instancier_programme @id, @par;
    COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
    SELECT @reference AS reference,
           N'Question ' + @reference + CASE WHEN @actif = 1 THEN N' ajoutée au programme.' ELSE N' retirée du programme.' END AS message;
END;

GO

