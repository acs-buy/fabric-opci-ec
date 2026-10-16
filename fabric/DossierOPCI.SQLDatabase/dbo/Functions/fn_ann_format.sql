CREATE   FUNCTION dbo.fn_ann_format (@fmt VARCHAR (10), @v DECIMAL (38, 12))
RETURNS NVARCHAR (100)
AS
BEGIN
    IF @v IS NULL RETURN NULL;
    IF @fmt = 'montant' RETURN dbo.fn_ann_grouper(@v, 2);
    IF @fmt = 'unitaire' RETURN dbo.fn_ann_grouper(@v, 4);
    IF @fmt = 'pct' RETURN dbo.fn_ann_grouper(@v * 100, 2) + NCHAR(160) + N'%';
    IF @fmt = 'surface' RETURN dbo.fn_ann_grouper(ROUND(@v, 0), 0) + NCHAR(160) + N'm²';
    IF @fmt = 'nombre'
    BEGIN
        IF @v = ROUND(@v, 0, 1) RETURN dbo.fn_ann_grouper(@v, 0);
        -- les decimales significatives
        DECLARE @dec NVARCHAR (40) = PARSENAME(CAST(ABS(@v) AS NVARCHAR (60)), 1);
        DECLARE @n INT = LEN(@dec);
        WHILE @n > 0 AND SUBSTRING(@dec, @n, 1) = N'0' SET @n -= 1;
        RETURN CASE WHEN @v < 0 THEN N'-' ELSE N'' END + dbo.fn_ann_grouper(ROUND(ABS(@v), 0, 1), 0) + N',' + LEFT(@dec, @n);
    END;
    RETURN CAST(@v AS NVARCHAR (100));
END;

GO

