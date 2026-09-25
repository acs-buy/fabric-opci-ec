
CREATE   VIEW dbo.v_ecran_fec_a_exporter AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[entite], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[arrete], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[lot_id], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[rang], 121), N'') AS cle_ecran, v.*
FROM dbo.v_fec_a_exporter v;

GO

