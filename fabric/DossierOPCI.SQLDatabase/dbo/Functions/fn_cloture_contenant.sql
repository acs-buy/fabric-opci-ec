
-- L'EXERCICE D'UNE ENTITE QUI CONTIENT UNE DATE, lu sur sa cloture « JJ-MM » ou « JJ/MM ». NULL si illisible.
CREATE   FUNCTION dbo.fn_cloture_contenant (@cloture VARCHAR (10), @date DATE)
RETURNS DATE
AS
BEGIN
    DECLARE @c VARCHAR (10) = REPLACE(LTRIM(RTRIM(@cloture)), '/', '-');
    IF @c NOT LIKE '[0-3][0-9]-[01][0-9]' RETURN NULL;
    DECLARE @j INT = CAST(LEFT(@c, 2) AS INT), @m INT = CAST(RIGHT(@c, 2) AS INT);
    IF @m NOT BETWEEN 1 AND 12 OR @j NOT BETWEEN 1 AND 31 RETURN NULL;
    DECLARE @d DATE = TRY_CAST(CONCAT(YEAR(@date), '-', RIGHT('0' + CAST(@m AS VARCHAR), 2), '-', RIGHT('0' + CAST(@j AS VARCHAR), 2)) AS DATE);
    IF @d IS NULL RETURN NULL;
    RETURN CASE WHEN @d >= @date THEN @d ELSE DATEADD(YEAR, 1, @d) END;
END;

GO

