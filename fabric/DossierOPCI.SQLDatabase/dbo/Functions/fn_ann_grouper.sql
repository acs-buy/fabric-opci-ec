
-- ------------------------------------------------------------------------------------------------- formats
-- Les formats de l'oracle (montant, nombre, pourcentage, unitaire, surface) : espace insecable U+00A0 pour les
-- milliers, virgule decimale, demi vers le haut (ROUND du T-SQL arrondit le demi en s'eloignant de zero, comme
-- ROUND_HALF_UP de l'oracle), jamais de « -0,00 ».
CREATE   FUNCTION dbo.fn_ann_grouper (@v DECIMAL (38, 12), @decimales INT)
RETURNS NVARCHAR (100)
AS
BEGIN
    IF @v IS NULL RETURN NULL;
    DECLARE @r DECIMAL (38, 12) = ROUND(@v, @decimales);
    DECLARE @t NVARCHAR (100) = FORMAT(ABS(@r), CASE @decimales WHEN 0 THEN N'#,0' ELSE N'#,0.' + REPLICATE(N'0', @decimales) END, 'en-US');
    SET @t = REPLACE(REPLACE(@t, N',', NCHAR(160)), N'.', N',');
    RETURN CASE WHEN @r < 0 THEN N'-' ELSE N'' END + @t;
END;

GO

