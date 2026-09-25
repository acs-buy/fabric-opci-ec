
CREATE   VIEW dbo.v_ecran_flux_intragroupe AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[id], 121), N'') AS cle_ecran, v.*
FROM dbo.v_flux_intragroupe v;

GO

