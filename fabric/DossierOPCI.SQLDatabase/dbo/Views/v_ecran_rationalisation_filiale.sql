
CREATE   VIEW dbo.v_ecran_rationalisation_filiale AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[entite_mere], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[filiale], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[arrete], 121), N'') AS cle_ecran, v.*
FROM dbo.v_rationalisation_filiale v;

GO

