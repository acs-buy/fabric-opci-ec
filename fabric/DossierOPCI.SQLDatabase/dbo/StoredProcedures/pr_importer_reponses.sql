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
    DECLARE @r329_blancs NVARCHAR (29) = NCHAR(9) + NCHAR(10) + NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(28) + NCHAR(29) + NCHAR(30) + NCHAR(31) + NCHAR(32) + NCHAR(133) + NCHAR(160) + NCHAR(5760) + NCHAR(8192) + NCHAR(8193) + NCHAR(8194) + NCHAR(8195) + NCHAR(8196) + NCHAR(8197) + NCHAR(8198) + NCHAR(8199) + NCHAR(8200) + NCHAR(8201) + NCHAR(8202) + NCHAR(8232) + NCHAR(8233) + NCHAR(8239) + NCHAR(8287) + NCHAR(12288);
    BEGIN TRY
    BEGIN TRANSACTION;
    WHILE @i <= @n
    BEGIN
        SELECT @ref = reference, @rep = reponse, @mo = motif, @co = commentaire FROM @t WHERE rang = @i;
        -- 329 (24/10/2026) : une reference blanche ou absente garde le refus 50241 d'avant le 327 (demande de la
        -- session du rapport) ; vide = str.isspace() de Python, comme au 327. Genere par
        -- 61_DEPLOIEMENT/generer_329_reimport_reference_blanche.py.
        IF ISNULL(DATALENGTH(TRIM(@r329_blancs COLLATE Latin1_General_100_BIN2 FROM @ref COLLATE Latin1_General_100_BIN2)), 0) = 0
            THROW 50241, N'La question désignée n''existe pas au référentiel.', 1;
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

