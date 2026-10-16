
-- Le libelle tel qu'un motif le cite : sans renvoi de bas de modele final (« (1) », « (1+2) ») ni deux-points final.
CREATE   FUNCTION dbo.fn_ann_libelle_recueil (@lib NVARCHAR (800))
RETURNS NVARCHAR (800)
AS
BEGIN
    DECLARE @t NVARCHAR (800) = LTRIM(RTRIM(ISNULL(@lib, N''))), @avant NVARCHAR (800) = NULL;
    WHILE @avant IS NULL OR @avant <> @t
    BEGIN
        SET @avant = @t;
        IF RIGHT(@t, 1) = N':' SET @t = RTRIM(LEFT(@t, LEN(@t) - 1));
        ELSE IF RIGHT(@t, 1) = N')' AND CHARINDEX(N'(', REVERSE(@t)) > 0
        BEGIN
            DECLARE @p INT = LEN(@t) - CHARINDEX(N'(', REVERSE(@t)) + 1;
            DECLARE @dedans NVARCHAR (800) = SUBSTRING(@t, @p + 1, LEN(@t) - @p - 1);
            IF @dedans <> N'' AND @dedans NOT LIKE N'%[^0-9+ ]%' AND LEFT(LTRIM(@dedans), 1) LIKE N'[0-9]' AND RIGHT(RTRIM(@dedans), 1) LIKE N'[0-9]'
                SET @t = RTRIM(LEFT(@t, @p - 1));
        END;
    END;
    RETURN @t;
END;

GO

