
-- 1. « L'état du patrimoine, par famille, en valeur actuelle », et la valeur nette d'inventaire (carte « 1 à 3 et 6 »).
CREATE   VIEW dbo.v_dip_rubrique_1 AS
SELECT g.entite, g.arrete, g.cle_arrete,
       f.famille, f.famille_libelle, f.ordre, f.nombre_actifs, f.valeur_actuelle, f.difference_estimation,
       v.actif_net_reevalue AS valeur_nette_inventaire,
       CAST(CASE WHEN f.famille IS NULL THEN N'à remplir' END AS NVARCHAR (20)) AS etat
FROM dbo.v_dip_arrete g
LEFT JOIN (SELECT entite, arrete, famille, famille_libelle, MIN(ordre) AS ordre, SUM(nombre_actifs) AS nombre_actifs,
                  SUM(valeur_actuelle) AS valeur_actuelle, SUM(difference_estimation) AS difference_estimation
           FROM dbo.v_client_patrimoine_famille GROUP BY entite, arrete, famille, famille_libelle) f
       ON f.entite = g.entite AND f.arrete = g.arrete
LEFT JOIN dbo.v_valeur_liquidative v ON v.entite = g.entite AND v.arrete = g.arrete;

GO

