
CREATE   VIEW dbo.v_ecran_comptes_non_rattaches AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[import_id], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[compte_num], 121), N'') AS cle_ecran, v.*
FROM dbo.v_comptes_non_rattaches v;

GO

