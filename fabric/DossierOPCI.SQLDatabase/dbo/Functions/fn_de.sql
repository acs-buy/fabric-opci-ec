
-- 0.2 : « de » s'elide devant une voyelle (« d'OMEGA-OPCI », « d'Associé signataire »).
CREATE   FUNCTION dbo.fn_de (@mot NVARCHAR (400))
RETURNS NVARCHAR (404)
AS
BEGIN
    RETURN CASE WHEN LEFT(@mot, 1) COLLATE Latin1_General_100_CI_AI LIKE N'[aeiouy]' THEN N'd''' ELSE N'de ' END + @mot;
END;

GO

