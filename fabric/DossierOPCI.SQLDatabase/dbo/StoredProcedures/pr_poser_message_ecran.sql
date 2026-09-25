
CREATE   PROCEDURE dbo.pr_poser_message_ecran
    @pour           NVARCHAR (400),
    @message        NVARCHAR (2000),
    @genre          VARCHAR (10)   = 'SUCCES',
    @entite         VARCHAR (20)   = NULL,
    @procedure_nom  VARCHAR (128)  = NULL,
    @geste          NVARCHAR (400) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- elle ne refuse JAMAIS : un message qui echoue ne doit pas masquer le geste qu'il rapporte
    IF @pour IS NULL OR LTRIM(RTRIM(@pour)) = N'' RETURN;
    IF @message IS NULL OR LTRIM(RTRIM(@message)) = N'' RETURN;
    SET @entite = ISNULL(NULLIF(LTRIM(RTRIM(@entite)), ''), '-');
    IF @genre NOT IN ('SUCCES', 'REFUS') SET @genre = 'SUCCES';

    -- UNE SEULE LIGNE VIVANTE par personne et par dossier : le dernier geste remplace le precedent,
    -- ce qui interdit qu'un refus survive a une reussite.
    UPDATE dbo.message_ecran
       SET genre = @genre, message = LEFT(@message, 2000), geste = @geste,
           procedure_nom = @procedure_nom, pose_le = SYSUTCDATETIME()
     WHERE pour = @pour AND entite = @entite;
    IF @@ROWCOUNT = 0
        INSERT INTO dbo.message_ecran (pour, entite, genre, message, geste, procedure_nom)
        VALUES (@pour, @entite, @genre, LEFT(@message, 2000), @geste, @procedure_nom);
END;

GO

