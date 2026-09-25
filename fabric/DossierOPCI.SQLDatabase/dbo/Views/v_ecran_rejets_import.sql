
CREATE   VIEW dbo.v_ecran_rejets_import AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[import_id], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[numero_ligne], 121), N'') AS cle_ecran, v.*
FROM dbo.v_rejets_import v;

GO

