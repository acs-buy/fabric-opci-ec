
-- ------------------------------------------------------------------ outils communs
-- Les verrous d'entite exclusifs des vehicules que l'ecriture d'une entite touche, dans l'ordre binaire des codes.
CREATE   PROCEDURE dbo.pr_e3_verrouiller @entite VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @v TABLE (entite VARCHAR (20) PRIMARY KEY, fait BIT NOT NULL DEFAULT 0);
    INSERT INTO @v (entite) SELECT entite FROM dbo.fn_ann_vehicules(@entite, 0, NULL);
    DECLARE @e VARCHAR (20);
    WHILE 1 = 1
    BEGIN
        SET @e = (SELECT TOP (1) entite FROM @v WHERE fait = 0 ORDER BY CAST(entite AS NVARCHAR (20)) COLLATE Latin1_General_100_BIN2);
        IF @e IS NULL BREAK;
        EXEC dbo.pr_ann_verrou @entite = @e;
        UPDATE @v SET fait = 1 WHERE entite = @e;
    END;
END;

GO

