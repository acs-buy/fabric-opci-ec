-- ------------------------------------------------------------------ un nombre saisi a la francaise : espaces retirees, virgule decimale ; NULL sinon
-- ecran 5, lot 1, script 323 (61_DEPLOIEMENT/generer_e5_323_procedures_de_tenue.py)
CREATE   FUNCTION dbo.fn_e5_nombre (@texte NVARCHAR (100))
RETURNS DECIMAL (38, 10)
AS
BEGIN
    -- en binaire : sous la collation de la base, REPLACE ne retire pas U+202F (SELECT relu le 19/10/2026)
    DECLARE @s NVARCHAR (100) = REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@texte)) COLLATE Latin1_General_BIN2, N' ', N''), NCHAR (160), N''), NCHAR (8239), N'');
    IF @s LIKE N'%,%' AND @s LIKE N'%.%' SET @s = REPLACE(@s, N'.', N'');
    SET @s = REPLACE(@s, N',', N'.');
    IF @s IS NULL OR @s = N'' OR @s LIKE N'%[^0-9.+-]%' RETURN NULL;
    RETURN TRY_CONVERT(DECIMAL (38, 10), @s);
END;

GO

