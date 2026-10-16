-- La cle naturelle d'une ligne (oracle, cle_naturelle) : les nombres compares comme des nombres, avant le texte a la
-- meme position ; a comparer en collation binaire.
CREATE   FUNCTION dbo.fn_ann_cle_naturelle (@s NVARCHAR (400))
RETURNS NVARCHAR (1600)
AS
BEGIN
    DECLARE @out NVARCHAR (1600) = N'', @i INT = 1, @n INT = LEN(@s + N'x') - 1, @c NCHAR (1), @num NVARCHAR (60) = N'';
    WHILE @i <= @n
    BEGIN
        SET @c = SUBSTRING(@s, @i, 1);
        IF @c LIKE N'[0-9]' SET @num += @c;
        ELSE
        BEGIN
            IF @num <> N'' SET @out += NCHAR(1) + RIGHT(REPLICATE(N'0', 20) + @num, 20);
            SET @num = N'';
            SET @out += @c;
        END;
        SET @i += 1;
    END;
    IF @num <> N'' SET @out += NCHAR(1) + RIGHT(REPLICATE(N'0', 20) + @num, 20);
    RETURN @out;
END;

GO

