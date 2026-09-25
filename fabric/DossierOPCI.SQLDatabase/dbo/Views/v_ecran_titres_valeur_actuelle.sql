
CREATE   VIEW dbo.v_ecran_titres_valeur_actuelle AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[entite_mere], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[entite_fille], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[arrete], 121), N'') AS cle_ecran, v.*
FROM dbo.v_titres_valeur_actuelle v;

GO

