
CREATE   VIEW dbo.v_ecran_ligne_annexe_montant AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[entite], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[arrete], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[article], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[code], 121), N'') AS cle_ecran, v.*
FROM dbo.v_ligne_annexe_montant v;

GO

