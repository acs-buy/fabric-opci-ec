
-- Les termes de la formule de calcul d'une ligne de ref_ligne_annexe (oracle, termes_formule, formule_termes) :
-- « signe|article|ligne|colonne » separes par « ; ».
CREATE   FUNCTION dbo.fn_ann_termes_formule (@art VARCHAR (10), @code VARCHAR (24), @col TINYINT)
RETURNS NVARCHAR (MAX)
AS
BEGIN
    DECLARE @f NVARCHAR (800) = (SELECT formule_calcul FROM dbo.ref_ligne_annexe WHERE article = @art AND code = @code);
    IF @f IS NULL RETURN N'';
    IF CHARINDEX(N';', @f) > 0 SET @f = LEFT(@f, CHARINDEX(N';', @f) - 1);
    DECLARE @out NVARCHAR (MAX) = N'', @i INT = 1, @n INT = LEN(@f), @ch NCHAR (1), @tok NVARCHAR (60) = N'', @sg INT = 1;
    WHILE @i <= @n + 1
    BEGIN
        SET @ch = CASE WHEN @i <= @n THEN SUBSTRING(@f, @i, 1) ELSE N' ' END;
        IF (@tok = N'' AND @ch COLLATE Latin1_General_100_BIN2 LIKE N'[A-Z]') OR (@tok <> N'' AND @ch COLLATE Latin1_General_100_BIN2 LIKE N'[A-Z0-9_]')
            SET @tok += @ch;
        ELSE
        BEGIN
            IF @tok <> N''
            BEGIN
                SET @out += CASE WHEN @out = N'' THEN N'' ELSE N';' END + CAST(@sg AS NVARCHAR (2)) + N'|' + @art + N'|' + @tok + N'|' + CAST(@col AS NVARCHAR (4));
                SET @tok = N''; SET @sg = 1;
            END;
            IF @ch = N'+' SET @sg = 1;
            ELSE IF @ch = N'-' SET @sg = -1;
        END;
        SET @i += 1;
    END;
    RETURN @out;
END;

GO

