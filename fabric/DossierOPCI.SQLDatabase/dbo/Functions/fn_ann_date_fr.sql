-- Une date AAAA-MM-JJ en JJ/MM/AAAA.
CREATE   FUNCTION dbo.fn_ann_date_fr (@d NVARCHAR (40))
RETURNS NVARCHAR (40)
AS
BEGIN
    IF @d IS NULL RETURN NULL;
    IF @d LIKE N'[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]%'
        RETURN SUBSTRING(@d, 9, 2) + N'/' + SUBSTRING(@d, 6, 2) + N'/' + LEFT(@d, 4);
    RETURN @d;
END;

GO

