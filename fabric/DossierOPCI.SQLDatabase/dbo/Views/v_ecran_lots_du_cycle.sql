
CREATE   VIEW dbo.v_ecran_lots_du_cycle AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[lot_id], 121), N'') AS cle_ecran, v.*
FROM dbo.v_lots_du_cycle v;

GO

