
-- --- 7. deposer une piece au coffre : l'inscription qui suit le televersement -----------------
CREATE   PROCEDURE dbo.pr_deposer_piece
    @entite         VARCHAR (20),
    @nom_fichier    NVARCHAR (400),
    @chemin_coffre  NVARCHAR (400),
    @empreinte      CHAR (64),
    @nature         VARCHAR (30),
    @arrete         VARCHAR (20)  = NULL,
    @question       VARCHAR (20)  = NULL,    -- la reference d'une question, quand la piece la justifie
    @periode_debut  DATE          = NULL,
    @periode_fin    DATE          = NULL,
    @par            NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @entite)
        THROW 50271, N'L''entité désignée n''existe pas.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_nature_piece WHERE code = @nature)
        THROW 50272, N'La nature de la pièce n''est pas au référentiel. Les natures se complètent à l''écran Référentiels.', 1;
    IF @arrete IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.ref_arrete WHERE entite = @entite AND arrete = @arrete)
        THROW 50273, N'L''arrêté désigné n''est pas au référentiel de cette entité.', 1;
    IF LEN(@empreinte) <> 64
        THROW 50274, N'L''empreinte SHA-256 du fichier fait 64 caractères.', 1;
    DECLARE @qid INT = NULL;
    IF @question IS NOT NULL
    BEGIN
        SET @qid = (SELECT id FROM dbo.ref_question WHERE reference = @question);
        IF @qid IS NULL THROW 50275, N'La question désignée n''existe pas.', 1;
    END;
    DECLARE @piece INT = (SELECT TOP (1) id FROM dbo.piece WHERE empreinte_sha256 = @empreinte);
    IF @piece IS NOT NULL
    BEGIN
        DECLARE @m NVARCHAR (400) = N'Ce fichier est déjà au coffre, pièce n° ' + CAST(@piece AS NVARCHAR (10)) + N' ; il n''est pas déposé deux fois.';
        THROW 50276, @m, 1;
    END;

    BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO dbo.piece (nom_fichier, chemin_coffre, empreinte_sha256, nature, periode_debut, periode_fin, depose_par, depose_le)
    VALUES (@nom_fichier, @chemin_coffre, @empreinte, @nature, @periode_debut, @periode_fin, @par, SYSUTCDATETIME());
    SET @piece = SCOPE_IDENTITY();
    INSERT INTO dbo.piece_rattachement (piece_id, entite, arrete, question_id, rattache_par, rattache_le)
    VALUES (@piece, @entite, @arrete, @qid, @par, SYSUTCDATETIME());
    COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @piece AS piece_id, N'Pièce « ' + @nom_fichier + N' » déposée au coffre de ' + @entite
         + CASE WHEN @question IS NOT NULL THEN N', rattachée à la question ' + @question ELSE N'' END + N'.' AS message;
END;

GO

