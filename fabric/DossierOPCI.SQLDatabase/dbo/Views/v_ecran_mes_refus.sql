
CREATE   VIEW dbo.v_ecran_mes_refus AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[id], 121), N'') AS cle_ecran, v.*
FROM dbo.v_mes_refus v;

GO

