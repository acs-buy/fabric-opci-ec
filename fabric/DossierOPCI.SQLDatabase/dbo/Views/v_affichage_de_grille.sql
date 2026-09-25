CREATE   VIEW dbo.v_affichage_de_grille AS
SELECT c.vue,
       c.ordre,
       c.colonne,
       c.visible,
       c.motif_du_masquage,
       -- Le libelle le plus SPECIFIQUE gagne, dans cet ordre : celui de la grille, celui de
       -- l'objet d'origine, puis le generique de portee '*'. A defaut, le nom technique.
       COALESCE(propre.libelle, origine.libelle, general.libelle, c.colonne) AS libelle_affiche,
       CAST(CASE WHEN COALESCE(propre.libelle, origine.libelle, general.libelle) IS NULL
                 THEN 0 ELSE 1 END AS bit)                                   AS libelle_pose,
       CASE WHEN propre.libelle  IS NOT NULL THEN 'grille'
            WHEN origine.libelle IS NOT NULL THEN 'objet d''origine'
            WHEN general.libelle IS NOT NULL THEN 'general'
            ELSE '' END                                                      AS portee_du_libelle
FROM dbo.v_colonne_de_grille c
LEFT JOIN dbo.ref_libelle_colonne propre
       ON propre.vue = c.vue AND propre.colonne = c.colonne
LEFT JOIN dbo.ref_libelle_colonne origine
       ON origine.vue = c.objet_des_masquages AND origine.colonne = c.colonne
LEFT JOIN dbo.ref_libelle_colonne general
       ON general.vue = '*' AND general.colonne = c.colonne;

GO

