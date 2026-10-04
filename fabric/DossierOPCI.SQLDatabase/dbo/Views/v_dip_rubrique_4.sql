
-- 4. « Le portefeuille : l'inventaire du patrimoine, articles 336-1 à 336-3 ».
CREATE   VIEW dbo.v_dip_rubrique_4 AS
SELECT g.entite, g.arrete, g.cle_arrete,
       p.code_actif, p.famille_libelle, p.adresse, p.article, p.source_libelle, p.valeur_comptable, p.valeur_actuelle,
       CAST(CASE WHEN p.code_actif IS NULL THEN N'à remplir' END AS NVARCHAR (20)) AS etat
FROM dbo.v_dip_arrete g
LEFT JOIN dbo.v_client_patrimoine_actif p ON p.entite = g.entite AND p.arrete = g.arrete;

GO

