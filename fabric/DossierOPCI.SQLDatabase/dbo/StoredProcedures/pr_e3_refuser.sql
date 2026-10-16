
-- Un refus « numero|message » leve en THROW (le % se double dans le texte d'un THROW).
CREATE   PROCEDURE dbo.pr_e3_refuser @refus NVARCHAR (1000)
AS
BEGIN
    DECLARE @n INT = CAST(LEFT(@refus, 5) AS INT), @m NVARCHAR (2000) = REPLACE(SUBSTRING(@refus, 7, 2000), N'%', N'%%');
    THROW @n, @m, 1;
END;

GO

