
CREATE   VIEW dbo.v_ecran_carnet_import AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[import_id], 121), N'') AS cle_ecran, v.*
FROM dbo.v_carnet_import v;

GO

