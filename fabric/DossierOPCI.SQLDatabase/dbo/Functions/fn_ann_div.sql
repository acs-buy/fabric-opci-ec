
-- Division a 12 decimales, sans perte d'echelle (x jusqu'a 10^18, y jusqu'a 10^16).
CREATE   FUNCTION dbo.fn_ann_div (@x DECIMAL (38, 12), @y DECIMAL (38, 12))
RETURNS DECIMAL (38, 12)
AS
BEGIN
    IF @x IS NULL OR @y IS NULL OR @y = 0 RETURN NULL;
    RETURN CAST(CAST(@x AS DECIMAL (24, 6)) / CAST(@y AS DECIMAL (24, 8)) AS DECIMAL (38, 12));
END;

GO

