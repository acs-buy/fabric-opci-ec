
-- --- 5. importer les reponses d'un classeur, tout ou rien -------------------------------------
-- @reponses est un tableau JSON : [{"reference":"ACC-A01","reponse":"OUI","motif":null,"commentaire":null}, ...]
CREATE   PROCEDURE dbo.pr_importer_reponses
    @cote      VARCHAR (30),
    @reponses  NVARCHAR (MAX),
    @par       NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.feuille_travail WHERE cote = @cote)
        THROW 50251, N'Le questionnaire désigné n''existe pas.', 1;
    IF ISJSON(@reponses) <> 1
        THROW 50252, N'Le contenu reçu n''est pas un tableau de réponses lisible.', 1;

    DECLARE @t TABLE (rang INT IDENTITY (1, 1), reference VARCHAR (20), reponse NVARCHAR (400),
                      motif NVARCHAR (800), commentaire NVARCHAR (2000));
    INSERT INTO @t (reference, reponse, motif, commentaire)
    SELECT reference, reponse, motif, commentaire
    FROM OPENJSON(@reponses) WITH (reference VARCHAR (20) '$.reference', reponse NVARCHAR (400) '$.reponse',
                                  motif NVARCHAR (800) '$.motif', commentaire NVARCHAR (2000) '$.commentaire')
    WHERE NULLIF(LTRIM(RTRIM(reponse)), N'') IS NOT NULL;

    DECLARE @n INT = (SELECT COUNT(*) FROM @t), @i INT = 1, @ref VARCHAR (20), @rep NVARCHAR (400),
            @mo NVARCHAR (800), @co NVARCHAR (2000);
    BEGIN TRY
    BEGIN TRANSACTION;
    WHILE @i <= @n
    BEGIN
        SELECT @ref = reference, @rep = reponse, @mo = motif, @co = commentaire FROM @t WHERE rang = @i;
        EXEC dbo.pr_repondre_question @cote, @ref, @rep, @mo, @co, @par;   -- un refus annule tout
        SET @i += 1;
    END;
    COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @cote AS cote, @n AS importees,
           (SELECT COUNT(*) FROM dbo.feuille_question fq JOIN dbo.ref_question q ON q.id = fq.question_id
             WHERE fq.cote = @cote AND q.obligatoire = 1 AND fq.reponse IS NULL AND fq.reponse_valeur IS NULL) AS obligatoires_restantes,
           CAST(@n AS NVARCHAR (10)) + N' réponses importées sur ' + @cote + N'.' AS message;
END;

GO

