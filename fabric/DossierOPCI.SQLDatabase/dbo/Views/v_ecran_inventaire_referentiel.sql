
CREATE   VIEW dbo.v_ecran_inventaire_referentiel AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[table_nom], 121), N'') AS cle_ecran, v.*
FROM dbo.v_inventaire_referentiel v;

GO

