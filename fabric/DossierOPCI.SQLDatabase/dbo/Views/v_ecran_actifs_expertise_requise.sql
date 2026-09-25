
CREATE   VIEW dbo.v_ecran_actifs_expertise_requise AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[code_actif], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[arrete], 121), N'') AS cle_ecran, v.*
FROM dbo.v_actifs_expertise_requise v;

GO

