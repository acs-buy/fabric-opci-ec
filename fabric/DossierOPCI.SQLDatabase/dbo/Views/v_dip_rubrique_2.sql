
-- 2. Les parts en circulation.
CREATE   VIEW dbo.v_dip_rubrique_2 AS
SELECT g.entite, g.arrete, g.cle_arrete, v.nombre_parts,
       CAST(CASE WHEN v.nombre_parts IS NULL THEN N'à remplir' END AS NVARCHAR (20)) AS etat
FROM dbo.v_dip_arrete g
LEFT JOIN dbo.v_valeur_liquidative v ON v.entite = g.entite AND v.arrete = g.arrete;

GO

