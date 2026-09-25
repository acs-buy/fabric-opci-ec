
CREATE   VIEW dbo.v_ecran_obligation_minimale AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[entite], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[exercice], 121), N'') AS cle_ecran, v.*
FROM dbo.v_obligation_minimale v;

GO

