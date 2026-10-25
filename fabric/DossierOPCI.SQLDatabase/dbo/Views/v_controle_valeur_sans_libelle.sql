-- La valeur codee presente en base sans libelle dans ref_libelle_valeur, colonne par colonne. ATTENDU zero.
-- Generee par 61_DEPLOIEMENT/generer_e5_319_libelles_classement_ecart.py sur les 52 colonnes de LIBELLES_VALEURS : une colonne codee qui s'ajoute se regenere.
CREATE   VIEW dbo.v_controle_valeur_sans_libelle AS
SELECT x.table_nom, x.colonne, x.valeur, x.lignes
FROM (
    SELECT CAST('modele_ecriture' AS VARCHAR (120)) AS table_nom, CAST('sens' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.sens) AS valeur, COUNT(*) AS lignes
    FROM dbo.modele_ecriture t WHERE t.sens IS NOT NULL GROUP BY t.sens
    UNION ALL
    SELECT CAST('modele_feuille' AS VARCHAR (120)) AS table_nom, CAST('standard' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.standard) AS valeur, COUNT(*) AS lignes
    FROM dbo.modele_feuille t WHERE t.standard IS NOT NULL GROUP BY t.standard
    UNION ALL
    SELECT CAST('ref_article' AS VARCHAR (120)) AS table_nom, CAST('dans_perimetre' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.dans_perimetre) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_article t WHERE t.dans_perimetre IS NOT NULL GROUP BY t.dans_perimetre
    UNION ALL
    SELECT CAST('ref_article' AS VARCHAR (120)) AS table_nom, CAST('source' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.source) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_article t WHERE t.source IS NOT NULL GROUP BY t.source
    UNION ALL
    SELECT CAST('ref_cas_eligibilite' AS VARCHAR (120)) AS table_nom, CAST('maitrise' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.maitrise) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_cas_eligibilite t WHERE t.maitrise IS NOT NULL GROUP BY t.maitrise
    UNION ALL
    SELECT CAST('ref_compte' AS VARCHAR (120)) AS table_nom, CAST('porte_actif' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.porte_actif) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_compte t WHERE t.porte_actif IS NOT NULL GROUP BY t.porte_actif
    UNION ALL
    SELECT CAST('ref_controle' AS VARCHAR (120)) AS table_nom, CAST('genre' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.genre) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_controle t WHERE t.genre IS NOT NULL GROUP BY t.genre
    UNION ALL
    SELECT CAST('ref_cycle' AS VARCHAR (120)) AS table_nom, CAST('applicabilite' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.applicabilite) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_cycle t WHERE t.applicabilite IS NOT NULL GROUP BY t.applicabilite
    UNION ALL
    SELECT CAST('ref_forme_conclusion' AS VARCHAR (120)) AS table_nom, CAST('favorable' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.favorable) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_forme_conclusion t WHERE t.favorable IS NOT NULL GROUP BY t.favorable
    UNION ALL
    SELECT CAST('ref_forme_rapport' AS VARCHAR (120)) AS table_nom, CAST('attestation' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.attestation) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_forme_rapport t WHERE t.attestation IS NOT NULL GROUP BY t.attestation
    UNION ALL
    SELECT CAST('ref_ligne_annexe' AS VARCHAR (120)) AS table_nom, CAST('globalisable' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.globalisable) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_ligne_annexe t WHERE t.globalisable IS NOT NULL GROUP BY t.globalisable
    UNION ALL
    SELECT CAST('ref_ligne_annexe' AS VARCHAR (120)) AS table_nom, CAST('signe' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.signe) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_ligne_annexe t WHERE t.signe IS NOT NULL GROUP BY t.signe
    UNION ALL
    SELECT CAST('ref_ligne_annexe' AS VARCHAR (120)) AS table_nom, CAST('type_ligne' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.type_ligne) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_ligne_annexe t WHERE t.type_ligne IS NOT NULL GROUP BY t.type_ligne
    UNION ALL
    SELECT CAST('ref_ligne_etat' AS VARCHAR (120)) AS table_nom, CAST('etat' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.etat) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_ligne_etat t WHERE t.etat IS NOT NULL GROUP BY t.etat
    UNION ALL
    SELECT CAST('ref_ligne_etat' AS VARCHAR (120)) AS table_nom, CAST('sens' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.sens) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_ligne_etat t WHERE t.sens IS NOT NULL GROUP BY t.sens
    UNION ALL
    SELECT CAST('ref_ligne_etat' AS VARCHAR (120)) AS table_nom, CAST('type_ligne' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.type_ligne) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_ligne_etat t WHERE t.type_ligne IS NOT NULL GROUP BY t.type_ligne
    UNION ALL
    SELECT CAST('ref_livrable' AS VARCHAR (120)) AS table_nom, CAST('applicable' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.applicable) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_livrable t WHERE t.applicable IS NOT NULL GROUP BY t.applicable
    UNION ALL
    SELECT CAST('ref_livrable' AS VARCHAR (120)) AS table_nom, CAST('nature' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.nature) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_livrable t WHERE t.nature IS NOT NULL GROUP BY t.nature
    UNION ALL
    SELECT CAST('ref_livrable' AS VARCHAR (120)) AS table_nom, CAST('produit_etape_6' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.produit_etape_6) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_livrable t WHERE t.produit_etape_6 IS NOT NULL GROUP BY t.produit_etape_6
    UNION ALL
    SELECT CAST('ref_nature_actif' AS VARCHAR (120)) AS table_nom, CAST('expertise_requise' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.expertise_requise) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_nature_actif t WHERE t.expertise_requise IS NOT NULL GROUP BY t.expertise_requise
    UNION ALL
    SELECT CAST('ref_nature_piece' AS VARCHAR (120)) AS table_nom, CAST('conservation' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.conservation) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_nature_piece t WHERE t.conservation IS NOT NULL GROUP BY t.conservation
    UNION ALL
    SELECT CAST('ref_nature_piece' AS VARCHAR (120)) AS table_nom, CAST('famille' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.famille) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_nature_piece t WHERE t.famille IS NOT NULL GROUP BY t.famille
    UNION ALL
    SELECT CAST('ref_norme' AS VARCHAR (120)) AS table_nom, CAST('applicable_presentation' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.applicable_presentation) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_norme t WHERE t.applicable_presentation IS NOT NULL GROUP BY t.applicable_presentation
    UNION ALL
    SELECT CAST('ref_norme' AS VARCHAR (120)) AS table_nom, CAST('autorite' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.autorite) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_norme t WHERE t.autorite IS NOT NULL GROUP BY t.autorite
    UNION ALL
    SELECT CAST('ref_norme' AS VARCHAR (120)) AS table_nom, CAST('en_vigueur' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.en_vigueur) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_norme t WHERE t.en_vigueur IS NOT NULL GROUP BY t.en_vigueur
    UNION ALL
    SELECT CAST('ref_obligation_distribution' AS VARCHAR (120)) AS table_nom, CAST('exercice_de_rattachement' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.exercice_de_rattachement) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_obligation_distribution t WHERE t.exercice_de_rattachement IS NOT NULL GROUP BY t.exercice_de_rattachement
    UNION ALL
    SELECT CAST('ref_parametre' AS VARCHAR (120)) AS table_nom, CAST('genre' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.genre) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_parametre t WHERE t.genre IS NOT NULL GROUP BY t.genre
    UNION ALL
    SELECT CAST('ref_phase' AS VARCHAR (120)) AS table_nom, CAST('niveau' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.niveau) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_phase t WHERE t.niveau IS NOT NULL GROUP BY t.niveau
    UNION ALL
    SELECT CAST('ref_piece_attendue' AS VARCHAR (120)) AS table_nom, CAST('obligatoire' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.obligatoire) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_piece_attendue t WHERE t.obligatoire IS NOT NULL GROUP BY t.obligatoire
    UNION ALL
    SELECT CAST('ref_piece_attendue' AS VARCHAR (120)) AS table_nom, CAST('periodicite' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.periodicite) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_piece_attendue t WHERE t.periodicite IS NOT NULL GROUP BY t.periodicite
    UNION ALL
    SELECT CAST('ref_question' AS VARCHAR (120)) AS table_nom, CAST('applicabilite' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.applicabilite) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_question t WHERE t.applicabilite IS NOT NULL GROUP BY t.applicabilite
    UNION ALL
    SELECT CAST('ref_question' AS VARCHAR (120)) AS table_nom, CAST('obligatoire' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.obligatoire) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_question t WHERE t.obligatoire IS NOT NULL GROUP BY t.obligatoire
    UNION ALL
    SELECT CAST('ref_question' AS VARCHAR (120)) AS table_nom, CAST('statut' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.statut) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_question t WHERE t.statut IS NOT NULL GROUP BY t.statut
    UNION ALL
    SELECT CAST('ref_question' AS VARCHAR (120)) AS table_nom, CAST('type_reponse' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.type_reponse) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_question t WHERE t.type_reponse IS NOT NULL GROUP BY t.type_reponse
    UNION ALL
    SELECT CAST('ref_question_article' AS VARCHAR (120)) AS table_nom, CAST('nature' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.nature) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_question_article t WHERE t.nature IS NOT NULL GROUP BY t.nature
    UNION ALL
    SELECT CAST('ref_ratio' AS VARCHAR (120)) AS table_nom, CAST('calcul_a_valider' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.calcul_a_valider) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_ratio t WHERE t.calcul_a_valider IS NOT NULL GROUP BY t.calcul_a_valider
    UNION ALL
    SELECT CAST('ref_ratio' AS VARCHAR (120)) AS table_nom, CAST('calculable' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.calculable) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_ratio t WHERE t.calculable IS NOT NULL GROUP BY t.calculable
    UNION ALL
    SELECT CAST('ref_ratio' AS VARCHAR (120)) AS table_nom, CAST('sens' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.sens) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_ratio t WHERE t.sens IS NOT NULL GROUP BY t.sens
    UNION ALL
    SELECT CAST('ref_ratio' AS VARCHAR (120)) AS table_nom, CAST('source_du_seuil' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.source_du_seuil) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_ratio t WHERE t.source_du_seuil IS NOT NULL GROUP BY t.source_du_seuil
    UNION ALL
    SELECT CAST('ref_ratio_memoire' AS VARCHAR (120)) AS table_nom, CAST('statut_grand_public' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.statut_grand_public) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_ratio_memoire t WHERE t.statut_grand_public IS NOT NULL GROUP BY t.statut_grand_public
    UNION ALL
    SELECT CAST('ref_ratio_memoire' AS VARCHAR (120)) AS table_nom, CAST('statut_professionnel' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.statut_professionnel) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_ratio_memoire t WHERE t.statut_professionnel IS NOT NULL GROUP BY t.statut_professionnel
    UNION ALL
    SELECT CAST('ref_ratio_memoire' AS VARCHAR (120)) AS table_nom, CAST('unite_seuil' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.unite_seuil) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_ratio_memoire t WHERE t.unite_seuil IS NOT NULL GROUP BY t.unite_seuil
    UNION ALL
    SELECT CAST('ref_ratio_memoire' AS VARCHAR (120)) AS table_nom, CAST('valeur_laissee' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.valeur_laissee) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_ratio_memoire t WHERE t.valeur_laissee IS NOT NULL GROUP BY t.valeur_laissee
    UNION ALL
    SELECT CAST('ref_ratio_vehicule' AS VARCHAR (120)) AS table_nom, CAST('source' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.source) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_ratio_vehicule t WHERE t.source IS NOT NULL GROUP BY t.source
    UNION ALL
    SELECT CAST('ref_reference' AS VARCHAR (120)) AS table_nom, CAST('genre' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.genre) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_reference t WHERE t.genre IS NOT NULL GROUP BY t.genre
    UNION ALL
    SELECT CAST('ref_reference' AS VARCHAR (120)) AS table_nom, CAST('lu_sur_piece' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.lu_sur_piece) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_reference t WHERE t.lu_sur_piece IS NOT NULL GROUP BY t.lu_sur_piece
    UNION ALL
    SELECT CAST('ref_role' AS VARCHAR (120)) AS table_nom, CAST('vise' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.vise) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_role t WHERE t.vise IS NOT NULL GROUP BY t.vise
    UNION ALL
    SELECT CAST('ref_rubrique_resultat' AS VARCHAR (120)) AS table_nom, CAST('famille' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.famille) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_rubrique_resultat t WHERE t.famille IS NOT NULL GROUP BY t.famille
    UNION ALL
    SELECT CAST('ref_source_valeur' AS VARCHAR (120)) AS table_nom, CAST('saisissable' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.saisissable) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_source_valeur t WHERE t.saisissable IS NOT NULL GROUP BY t.saisissable
    UNION ALL
    SELECT CAST('ref_tableau_annexe' AS VARCHAR (120)) AS table_nom, CAST('indicatif' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.indicatif) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_tableau_annexe t WHERE t.indicatif IS NOT NULL GROUP BY t.indicatif
    UNION ALL
    SELECT CAST('ref_tableau_annexe' AS VARCHAR (120)) AS table_nom, CAST('principe' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.principe) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_tableau_annexe t WHERE t.principe IS NOT NULL GROUP BY t.principe
    UNION ALL
    SELECT CAST('ref_tableau_annexe' AS VARCHAR (120)) AS table_nom, CAST('source_valeur' AS VARCHAR (128)) AS colonne, CONVERT(NVARCHAR (30), t.source_valeur) AS valeur, COUNT(*) AS lignes
    FROM dbo.ref_tableau_annexe t WHERE t.source_valeur IS NOT NULL GROUP BY t.source_valeur
) x
WHERE NOT EXISTS (SELECT 1 FROM dbo.ref_libelle_valeur l
                  WHERE l.table_nom = x.table_nom AND l.colonne = x.colonne AND l.valeur = x.valeur);

GO

