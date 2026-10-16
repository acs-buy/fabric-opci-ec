
-- pr_ann_verrou : 1 refus
-- Le verrou d'entite d'une transaction ouverte (contrat, 2.2, point 6).
CREATE   PROCEDURE dbo.pr_ann_verrou @entite VARCHAR (20), @mode VARCHAR (10) = 'Exclusive'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @res NVARCHAR (255) = N'annexe:' + CAST(@entite AS NVARCHAR (20)), @rc INT;
    EXEC @rc = sp_getapplock @Resource = @res, @LockMode = @mode, @LockOwner = 'Transaction', @LockTimeout = 120000;
    IF @rc < 0
    BEGIN
        DECLARE @m NVARCHAR (400) = N'L''annexe de l''entité ' + @entite + N' est en cours de calcul : réessayez dans un instant.';
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50642, @m, 1; END
    END;
END;

GO

