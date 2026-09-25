
CREATE   VIEW dbo.v_ecran_ecritures_du_compte AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[ecriture_id], 121), N'') AS cle_ecran, v.*
FROM dbo.v_ecritures_du_compte v;

GO

