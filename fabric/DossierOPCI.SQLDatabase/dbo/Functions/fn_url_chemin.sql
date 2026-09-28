
-- L'ADRESSE D'UN CHEMIN, pour composer un lien SharePoint. Identique au lien que rend Graph, soit urllib.parse.quote(safe='/-._~()'),
-- eprouve le 28/09/2026 sur un nom accentue, avec espace, diese et parentheses.
CREATE   FUNCTION dbo.fn_url_chemin (@chemin NVARCHAR (400))
RETURNS NVARCHAR (1200)
AS
BEGIN
    -- Chaque caractere hors de A-Z a-z 0-9 - . _ ~ / ( ) est ecrit en %XX, octet par octet de son UTF-8.
    -- Les parentheses restent, comme dans le lien que rend Graph, compare le 28/09/2026.
    DECLARE @r NVARCHAR (1200) = N'', @i INT = 1, @c NVARCHAR (1), @b VARBINARY (8), @j INT;
    WHILE @i <= LEN(@chemin + N'x') - 1
    BEGIN
        SET @c = SUBSTRING(@chemin, @i, 1);
        IF @c COLLATE Latin1_General_BIN2 LIKE N'[-A-Za-z0-9./_~()]'
            SET @r = @r + @c;
        ELSE
        BEGIN
            SET @b = CAST(CAST(@c COLLATE Latin1_General_100_CI_AS_SC_UTF8 AS VARCHAR (8)) AS VARBINARY (8));
            SET @j = 1;
            WHILE @j <= DATALENGTH(@b)
            BEGIN
                SET @r = @r + N'%' + CONVERT(NVARCHAR (2), SUBSTRING(@b, @j, 1), 2);
                SET @j = @j + 1;
            END;
        END;
        SET @i = @i + 1;
    END;
    RETURN @r;
END;

GO

