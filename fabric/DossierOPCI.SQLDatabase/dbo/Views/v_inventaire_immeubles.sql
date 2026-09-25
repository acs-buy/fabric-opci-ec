

-- --- 3 : l'inventaire rendu, actif par actif ------------------------
-- Ce que l'ecran L1c-24 affiche : une ligne par actif, avec ce que
-- l'article 336-2 exige. La vue lit dbo.actif et dbo.v_valeur_actuelle_actif,
-- et non les seules racines de comptes : l'inventaire est par ACTIF.
CREATE   VIEW dbo.v_inventaire_immeubles AS
SELECT v.entite, v.arrete, v.code_actif,
       a.adresse, a.surface_m2, a.secteur, a.date_acquisition,
       a.prix_de_revient,
       v.valeur_actuelle,
       v.difference_estimation,
       CAST(CASE WHEN an.actif_net_reevalue = 0 THEN NULL
                 ELSE v.valeur_actuelle / an.actif_net_reevalue END
            AS DECIMAL (9,6))                   AS pct_actif_net,
       v.poste_bilan,
       -- Le degre de liberte de l'article 336-2.
       N'Article 336-2 : la valeur actuelle et le % de l''actif net peuvent être donnés de façon globale, et non actif par actif'
                                                AS liberte_du_texte,
       -- Ce qui manque pour que la ligne soit complete.
       CASE WHEN a.adresse IS NULL AND a.surface_m2 IS NULL
                                   AND a.secteur IS NULL
            THEN N'adresse, surface et secteur à saisir'
            WHEN a.adresse IS NULL THEN N'adresse à saisir'
            WHEN a.surface_m2 IS NULL THEN N'surface à saisir'
            WHEN a.secteur IS NULL THEN N'secteur à saisir'
            ELSE N'complet' END                 AS etat
FROM dbo.v_valeur_actuelle_actif v
JOIN dbo.actif a ON a.code = v.code_actif
LEFT JOIN dbo.v_anr_entite an ON an.entite = v.entite AND an.arrete = v.arrete;

GO

