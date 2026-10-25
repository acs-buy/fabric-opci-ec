-- Objet n° 2 de l'ecran 5 (lot 1) : l'inventaire des referentiels, calcule en direct sur chaque table inscrite, sans
-- la table inventaire_referentiel ni sa procedure de releve, qui restent en base sans lecteur. Les 10 colonnes
-- d'avant gardent nom, type et nullabilite (table du modele publie, en directQuery) ; derniere_modification reste
-- un datetime2(3), son texte va dans derniere_modification_texte ; releve_le est l'heure de la lecture.
-- Etat, dans cet ordre : « aucune ligne », « n a valider » (questions A_AUDITER), « non modifiable » (mode TEXTE),
-- « n modifiee(s) », « importe » ; une table inscrite apres la generation se lit « non recense » : regenerer.
-- Nombres de l'etat comme la page : « n a valider » au separateur de milliers U+0020, « n modifiee(s) » sans.
-- Pour ref_parametre, pose_le et pose_par, une pose par « installation » comptant comme importee.
-- effet_annexe : le nombre de vehicules que marque le declencheur tr_<table>_annexe_retard, 0 sans lui ; ceux de
-- ref_entite, ref_compte_entite et saisie_annexe (fn_ann_vehicules) ne marquent que les vehicules de l'entite
-- modifiee : pour eux, ce nombre est un plafond.
-- Pose par 63_SQL/322_e5_vues_choix_inventaire_seuils_articles.sql, genere par 61_DEPLOIEMENT/generer_e5_322_vues_choix_inventaire_seuils_articles.py ;
-- ne pas modifier a la main : regenerer le script quand une table s'inscrit ou qu'une colonne change.
CREATE   VIEW dbo.v_inventaire_referentiel AS
WITH t AS (
    SELECT CAST('ref_compte' AS VARCHAR (120)) AS table_nom, COUNT(*) AS lignes, COUNT(x.modifie_le) AS lignes_modifiees,
           CAST(MAX(x.modifie_le) AS DATETIME2 (3)) AS derniere,
           CAST((SELECT TOP (1) y.modifie_par FROM dbo.ref_compte y WHERE y.modifie_le IS NOT NULL
                 ORDER BY y.modifie_le DESC, y.modifie_par DESC) AS NVARCHAR (400)) AS modifie_par,
           0 AS a_valider, 1 AS marque_annexe
    FROM dbo.ref_compte x
    UNION ALL
    SELECT CAST('ref_compte_entite' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_compte_entite y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 1 AS marque_annexe
    FROM dbo.ref_compte_entite x
    UNION ALL
    SELECT CAST('ref_cycle' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_cycle y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_cycle x
    UNION ALL
    SELECT CAST('ref_phase' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_phase y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_phase x
    UNION ALL
    SELECT CAST('ref_question' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_question y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           ISNULL(SUM(CASE WHEN x.statut = 'A_AUDITER' THEN 1 ELSE 0 END), 0) AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_question x
    UNION ALL
    SELECT CAST('ref_question_article' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_question_article y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_question_article x
    UNION ALL
    SELECT CAST('ref_article' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_article y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_article x
    UNION ALL
    SELECT CAST('ref_reference' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_reference y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 1 AS marque_annexe
    FROM dbo.ref_reference x
    UNION ALL
    SELECT CAST('ref_norme' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_norme y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 1 AS marque_annexe
    FROM dbo.ref_norme x
    UNION ALL
    SELECT CAST('modele_feuille' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.modele_feuille y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.modele_feuille x
    UNION ALL
    SELECT CAST('ref_question_modele' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_question_modele y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_question_modele x
    UNION ALL
    SELECT CAST('modele_ecriture' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.modele_ecriture y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.modele_ecriture x
    UNION ALL
    SELECT CAST('ref_piece_attendue' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_piece_attendue y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_piece_attendue x
    UNION ALL
    SELECT CAST('ref_nature_piece' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_nature_piece y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_nature_piece x
    UNION ALL
    SELECT CAST('ref_nature_actif' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_nature_actif y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 1 AS marque_annexe
    FROM dbo.ref_nature_actif x
    UNION ALL
    SELECT CAST('ref_contrepartie_estimation' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_contrepartie_estimation y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_contrepartie_estimation x
    UNION ALL
    SELECT CAST('ref_correspondance_plan' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_correspondance_plan y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_correspondance_plan x
    UNION ALL
    SELECT CAST('ref_nature_arrete' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_nature_arrete y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_nature_arrete x
    UNION ALL
    SELECT CAST('ref_forme_conclusion' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_forme_conclusion y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_forme_conclusion x
    UNION ALL
    SELECT CAST('ref_entite' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_entite y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 1 AS marque_annexe
    FROM dbo.ref_entite x
    UNION ALL
    SELECT CAST('ref_role' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_role y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_role x
    UNION ALL
    SELECT CAST('role_nature_visa' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.role_nature_visa y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.role_nature_visa x
    UNION ALL
    SELECT CAST('ref_question_reference' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_question_reference y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_question_reference x
    UNION ALL
    SELECT CAST('ref_rubrique_resultat' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_rubrique_resultat y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_rubrique_resultat x
    UNION ALL
    SELECT CAST('ref_ratio' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_ratio y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_ratio x
    UNION ALL
    SELECT CAST('ref_categorie_actif_cmf' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_categorie_actif_cmf y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_categorie_actif_cmf x
    UNION ALL
    SELECT CAST('ref_obligation_distribution' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_obligation_distribution y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_obligation_distribution x
    UNION ALL
    SELECT CAST('ref_ligne_etat' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_ligne_etat y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 1 AS marque_annexe
    FROM dbo.ref_ligne_etat x
    UNION ALL
    SELECT CAST('ref_tableau_annexe' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_tableau_annexe y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 1 AS marque_annexe
    FROM dbo.ref_tableau_annexe x
    UNION ALL
    SELECT CAST('saisie_annexe' AS VARCHAR (120)) AS table_nom, COUNT(*), 0, CAST(NULL AS DATETIME2 (3)), CAST(NULL AS NVARCHAR (400)), 0 AS a_valider, 1 AS marque_annexe
    FROM dbo.saisie_annexe x
    UNION ALL
    SELECT CAST('ref_livrable' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_livrable y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_livrable x
    UNION ALL
    SELECT CAST('ref_ligne_annexe' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_ligne_annexe y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 1 AS marque_annexe
    FROM dbo.ref_ligne_annexe x
    UNION ALL
    SELECT CAST('ref_cas_eligibilite' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_cas_eligibilite y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_cas_eligibilite x
    UNION ALL
    SELECT CAST('ref_cas_immeuble' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_cas_immeuble y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_cas_immeuble x
    UNION ALL
    SELECT CAST('ref_droit_reel' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_droit_reel y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_droit_reel x
    UNION ALL
    SELECT CAST('ref_controle' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_controle y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_controle x
    UNION ALL
    SELECT CAST('ref_forme_rapport' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_forme_rapport y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_forme_rapport x
    UNION ALL
    SELECT CAST('ref_source_valeur' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_source_valeur y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_source_valeur x
    UNION ALL
    SELECT CAST('ref_ratio_memoire' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_ratio_memoire y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_ratio_memoire x
    UNION ALL
    SELECT CAST('ref_ratio_vehicule' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_ratio_vehicule y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_ratio_vehicule x
    UNION ALL
    SELECT CAST('ref_cycle_compte' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_cycle_compte y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_cycle_compte x
    UNION ALL
    SELECT CAST('ref_question_compte' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_question_compte y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_question_compte x
    UNION ALL
    SELECT CAST('ref_parametre' AS VARCHAR (120)) AS table_nom, COUNT(*) AS lignes,
           ISNULL(SUM(CASE WHEN ISNULL(x.pose_par, N'') <> N'installation' THEN 1 ELSE 0 END), 0) AS lignes_modifiees,
           MAX(CASE WHEN ISNULL(x.pose_par, N'') <> N'installation' THEN x.pose_le END) AS derniere,
           (SELECT TOP (1) y.pose_par FROM dbo.ref_parametre y WHERE ISNULL(y.pose_par, N'') <> N'installation'
            ORDER BY y.pose_le DESC, y.pose_par DESC) AS modifie_par,
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_parametre x
    UNION ALL
    SELECT CAST('ref_sujet_tenue' AS VARCHAR (120)) AS table_nom, COUNT(*), COUNT(x.modifie_le), MAX(x.modifie_le),
           (SELECT TOP (1) y.modifie_par FROM dbo.ref_sujet_tenue y WHERE y.modifie_le IS NOT NULL
            ORDER BY y.modifie_le DESC, y.modifie_par DESC),
           0 AS a_valider, 0 AS marque_annexe
    FROM dbo.ref_sujet_tenue x
),
veh AS (SELECT COUNT(*) AS n FROM dbo.ref_entite WHERE forme_vehicule IS NOT NULL)
SELECT r.ordre, r.libelle, r.ecran_lu, r.qui_tient,
       COALESCE(t.lignes, 0) AS lignes,
       COALESCE(t.lignes_modifiees, 0) AS lignes_modifiees,
       CAST(t.derniere AS DATETIME2 (3)) AS derniere_modification,
       CAST(CASE WHEN t.table_nom IS NULL THEN N'non recensé'
                 WHEN t.lignes = 0 THEN N'aucune ligne'
                 WHEN t.a_valider > 0 THEN REPLACE(REPLACE(FORMAT(t.a_valider, 'N0', 'fr-FR') COLLATE Latin1_General_100_BIN2, NCHAR(8239), N' '), NCHAR(160), N' ') COLLATE DATABASE_DEFAULT + N' à valider'
                 WHEN r.mode_tenue = 'TEXTE' THEN N'non modifiable'
                 WHEN t.lignes_modifiees > 0 THEN CAST(t.lignes_modifiees AS NVARCHAR (12)) + CASE WHEN t.lignes_modifiees < 2 THEN N' modifiée' ELSE N' modifiées' END
                 ELSE N'importé' END AS NVARCHAR (51)) AS etat,
       CASE WHEN t.table_nom IS NULL THEN NULL ELSE CAST(SYSUTCDATETIME() AS DATETIME2 (3)) END AS releve_le,
       r.table_nom,
       CAST(CASE WHEN t.marque_annexe = 1 THEN v.n ELSE 0 END AS INT) AS effet_annexe,
       CAST(CASE WHEN t.table_nom IS NULL THEN N'non recensé'
                 WHEN t.lignes = 0 THEN N'aucune ligne'
                 WHEN t.a_valider > 0 THEN N'à valider'
                 WHEN r.mode_tenue = 'TEXTE' THEN N'non modifiable'
                 WHEN t.lignes_modifiees > 0 THEN N'modifié'
                 ELSE N'importé' END AS NVARCHAR (20)) AS etat_genre,
       CAST(ROW_NUMBER() OVER (ORDER BY CASE WHEN r.categorie_ordre IS NULL THEN 1 ELSE 0 END, r.categorie_ordre,
                                        r.rang_categorie, r.ordre) AS INT) AS rang,
       r.du_cabinet,
       CAST(t.modifie_par AS NVARCHAR (400)) AS modifie_par,
       r.domaine, r.domaine_ordre, r.categorie, r.categorie_ordre, r.mode_tenue,
       CAST(CASE WHEN r.mode_tenue = 'TEXTE' THEN N'fixé par un texte' ELSE N'mis à jour par le cabinet' END AS NVARCHAR (30)) AS mode_libelle,
       CAST(CASE WHEN r.mode_tenue = 'TEXTE' THEN N'aucun utilisateur'
                 WHEN r.qui_tient = 'REVISEUR' THEN N'l’associé ou le réviseur'
                 ELSE N'l’associé' END AS NVARCHAR (30)) AS qui_libelle,
       CAST(CASE WHEN t.table_nom IS NULL THEN NULL
                 WHEN t.derniere IS NOT NULL THEN CONVERT(NVARCHAR (10), t.derniere, 103)
                 WHEN t.lignes = 0 THEN N'sans objet'
                 ELSE N'importé' END AS NVARCHAR (10)) AS derniere_modification_texte
FROM dbo.ref_referentiel r
LEFT JOIN t ON t.table_nom = r.table_nom
CROSS JOIN veh v;

GO

