
CREATE   VIEW dbo.v_ecran_simulation_distribution AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[cle_arrete], 121), N'') AS cle_ecran, v.*
FROM dbo.v_simulation_distribution v;

GO

