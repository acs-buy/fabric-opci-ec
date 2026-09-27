
CREATE   PROCEDURE dbo.pr_poser_parametre
    @code   VARCHAR (40),
    @valeur NVARCHAR (800),
    @par    NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    IF @code IS NULL OR LTRIM(RTRIM(@code)) = ''
        THROW 50930, N'Le code du paramètre est obligatoire.', 1;
    MERGE dbo.ref_parametre AS c
    USING (SELECT @code AS code) AS n ON c.code = n.code
    WHEN MATCHED THEN UPDATE SET valeur = @valeur, pose_par = @par, pose_le = SYSUTCDATETIME()
    WHEN NOT MATCHED THEN INSERT (code, valeur, pose_par) VALUES (@code, @valeur, @par);
    SELECT @code AS code, @valeur AS valeur, N'Paramètre enregistré.' AS message;
END;

GO

