
-- 3. La valeur par part, celle que la page affiche : actif net reevalue / nombre de parts.
CREATE   VIEW dbo.v_dip_rubrique_3 AS
SELECT g.entite, g.arrete, g.cle_arrete, v.actif_net_reevalue, v.nombre_parts, v.valeur_liquidative AS valeur_par_part,
       CAST(CASE WHEN v.valeur_liquidative IS NULL THEN N'à remplir' END AS NVARCHAR (20)) AS etat
FROM dbo.v_dip_arrete g
LEFT JOIN dbo.v_valeur_liquidative v ON v.entite = g.entite AND v.arrete = g.arrete;

GO

