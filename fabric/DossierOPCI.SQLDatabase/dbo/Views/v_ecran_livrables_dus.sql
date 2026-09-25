
CREATE   VIEW dbo.v_ecran_livrables_dus AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[entite], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[arrete], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[livrable], 121), N'') AS cle_ecran, v.*
FROM dbo.v_livrables_dus v;

GO

