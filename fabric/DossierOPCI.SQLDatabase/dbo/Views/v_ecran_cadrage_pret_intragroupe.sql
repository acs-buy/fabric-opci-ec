
CREATE   VIEW dbo.v_ecran_cadrage_pret_intragroupe AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[arrete], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[filiale], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[opci], 121), N'') AS cle_ecran, v.*
FROM dbo.v_cadrage_pret_intragroupe v;

GO

