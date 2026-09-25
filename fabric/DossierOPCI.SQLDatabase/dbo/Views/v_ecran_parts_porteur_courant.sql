
CREATE   VIEW dbo.v_ecran_parts_porteur_courant AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[cle_arrete], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[porteur_id], 121), N'') AS cle_ecran, v.*
FROM dbo.v_parts_porteur_courant v;

GO

