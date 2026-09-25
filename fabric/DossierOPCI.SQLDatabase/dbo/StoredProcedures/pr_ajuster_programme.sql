
CREATE   PROCEDURE dbo.pr_ajuster_programme
    @entite     VARCHAR (20),
    @arrete     VARCHAR (20),
    @reference  VARCHAR (20),
    @actif      BIT,                 -- 1 ajoute, 0 retire
    @par        NVARCHAR (400)
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

    BEGIN TRY
    BEGIN TRANSACTION;
    IF EXISTS (SELECT 1 FROM dbo.programme_question WHERE programme_id = @id AND question_id = @qid)
        UPDATE dbo.programme_question SET actif = @actif, modifie_par = @par, modifie_le = SYSUTCDATETIME()
        WHERE programme_id = @id AND question_id = @qid;
    ELSE
        INSERT INTO dbo.programme_question (programme_id, question_id, actif, origine, modifie_par)
        VALUES (@id, @qid, @actif, 'AJOUT', @par);
    INSERT INTO dbo.programme_journal (programme_id, question_id, geste, detail, par)
    VALUES (@id, @qid, CASE WHEN @actif = 1 THEN 'AJOUT' ELSE 'RETRAIT' END, @reference, @par);
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

