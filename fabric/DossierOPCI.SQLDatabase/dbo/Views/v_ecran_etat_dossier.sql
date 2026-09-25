
CREATE   VIEW dbo.v_ecran_etat_dossier AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[entite], 121), N'') AS cle_ecran, v.*
FROM dbo.v_etat_dossier v;

GO

