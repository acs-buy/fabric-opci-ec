
CREATE   VIEW dbo.v_ecran_a_viser_derogation AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[nature], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[objet_ref], 121), N'') AS cle_ecran, v.*
FROM dbo.v_a_viser_derogation v;

GO

