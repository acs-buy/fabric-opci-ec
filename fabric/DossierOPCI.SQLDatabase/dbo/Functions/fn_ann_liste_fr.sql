-- « a », « a et b », « a, b et c », d'une liste separee par des virgules (oracle, liste_fr).
CREATE   FUNCTION dbo.fn_ann_liste_fr (@csv NVARCHAR (4000))
RETURNS NVARCHAR (4000)
AS
BEGIN
    DECLARE @x TABLE (n BIGINT, v NVARCHAR (400));
    INSERT INTO @x SELECT ordinal, LTRIM(RTRIM(value)) FROM STRING_SPLIT(ISNULL(@csv, N''), N',', 1) WHERE LTRIM(RTRIM(value)) <> N'';
    DECLARE @dernier BIGINT = (SELECT MAX(n) FROM @x);
    IF (SELECT COUNT(*) FROM @x) <= 1 RETURN ISNULL((SELECT v FROM @x), N'');
    RETURN (SELECT STRING_AGG(v, N', ') WITHIN GROUP (ORDER BY n) FROM @x WHERE n < @dernier) + N' et ' + (SELECT v FROM @x WHERE n = @dernier);
END;

GO

