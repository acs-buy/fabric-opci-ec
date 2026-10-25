-- Objet n° 5 de l'ecran 5 (lot 1) : les referentiels du cabinet (du_cabinet = 1), table des segments Domaine,
-- Categorie et Referentiel ; ordre : le rang de la grille de l'etape 1, categorie_ordre puis rang_categorie ;
-- forme_cle : vide pour un code d'une colonne, les libelles effectifs des colonnes du code (ref_libelle_colonne,
-- vue de la table puis '*') joints par « · », 1re lettre en minuscule, « numerotee » pour une cle numerotee par la
-- base ; designation : colonne_designation ; adresse_fichiers : le dossier Modeles de la bibliotheque Documents du
-- site du cabinet (SITE_CABINET), pour modele_feuille seul ; colonnes des cles relues au catalogue a la generation.
-- Pose par 63_SQL/322_e5_vues_choix_inventaire_seuils_articles.sql, genere par 61_DEPLOIEMENT/generer_e5_322_vues_choix_inventaire_seuils_articles.py ;
-- ne pas modifier a la main : regenerer le script quand une table s'inscrit ou qu'une colonne change.
CREATE   VIEW dbo.v_ecran_referentiel_choix AS
WITH cle_colonne AS (
    SELECT table_nom, rang, colonne, defaut FROM (VALUES
        ('ref_question_article', 1, 'question_id', N'question_id'),
        ('ref_question_article', 2, 'article', N'article'),
        ('ref_question_modele', 1, 'question_id', N'question_id'),
        ('ref_question_modele', 2, 'modele_code', N'modele_code'),
        ('ref_correspondance_plan', 1, 'norme_source', N'norme_source'),
        ('ref_correspondance_plan', 2, 'compte_source', N'compte_source'),
        ('role_nature_visa', 1, 'role_code', N'role_code'),
        ('role_nature_visa', 2, 'nature', N'nature'),
        ('ref_question_reference', 1, 'question_reference', N'question_reference'),
        ('ref_question_reference', 2, 'reference_id', N'Référence'),
        ('ref_ligne_etat', 1, 'etat', N'etat'),
        ('ref_ligne_etat', 2, 'code', N'code'),
        ('ref_ligne_annexe', 1, 'article', N'article'),
        ('ref_ligne_annexe', 2, 'code', N'code'),
        ('ref_ratio_vehicule', 1, 'entite', N'entite'),
        ('ref_ratio_vehicule', 2, 'code', N'code'),
        ('ref_cycle_compte', 1, 'cycle', N'cycle'),
        ('ref_cycle_compte', 2, 'racine', N'racine'),
        ('ref_question_compte', 1, 'question_id', N'question_id'),
        ('ref_question_compte', 2, 'racine', N'racine')
    ) v (table_nom, rang, colonne, defaut)
),
numerotee AS (
    SELECT table_nom FROM (VALUES ('ref_question'), ('ref_reference'), ('modele_ecriture'), ('ref_piece_attendue')) v (table_nom)
),
libelle_cle AS (
    SELECT k.table_nom, k.rang,
           COALESCE((SELECT TOP (1) l.libelle FROM dbo.ref_libelle_colonne l
                     WHERE l.colonne = k.colonne AND l.vue IN (k.table_nom, '*')
                     ORDER BY CASE WHEN l.vue = '*' THEN 1 ELSE 0 END), k.defaut) AS libelle
    FROM cle_colonne k
),
forme AS (
    SELECT table_nom,
           STRING_AGG(CAST(LOWER(LEFT(libelle, 1)) + SUBSTRING(libelle, 2, 200) AS NVARCHAR (MAX)), N' · ')
               WITHIN GROUP (ORDER BY rang) AS forme_cle
    FROM libelle_cle GROUP BY table_nom
),
site AS (
    SELECT MAX(CASE WHEN p.valeur LIKE N'%_:/sites/_%' THEN N'https://' + REPLACE(LTRIM(RTRIM(p.valeur)), N':/sites/', N'/sites/')
                    + N'/Documents%20partages/Modeles' END) AS adresse
    FROM dbo.ref_parametre p WHERE p.code = 'SITE_CABINET'
)
SELECT r.table_nom, r.libelle, r.mode_tenue, r.domaine, r.domaine_ordre, r.categorie, r.categorie_ordre,
       CAST(ROW_NUMBER() OVER (ORDER BY CASE WHEN r.categorie_ordre IS NULL THEN 1 ELSE 0 END, r.categorie_ordre,
                                        r.rang_categorie, r.ordre) AS INT) AS ordre,
       CAST(CASE WHEN n.table_nom IS NOT NULL THEN N'numérotée' ELSE f.forme_cle END AS NVARCHAR (200)) AS forme_cle,
       r.colonne_designation AS designation, r.actions_de_ligne, r.action_propre,
       CAST(CASE WHEN r.table_nom = 'modele_feuille' THEN s.adresse END AS NVARCHAR (800)) AS adresse_fichiers
FROM dbo.ref_referentiel r
LEFT JOIN forme f ON f.table_nom = r.table_nom
LEFT JOIN numerotee n ON n.table_nom = r.table_nom
CROSS JOIN site s
WHERE r.du_cabinet = 1;

GO

