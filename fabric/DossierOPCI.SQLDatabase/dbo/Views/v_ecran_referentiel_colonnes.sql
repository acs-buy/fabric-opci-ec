CREATE   VIEW dbo.v_ecran_referentiel_colonnes AS
SELECT CAST(t.referentiel AS VARCHAR (120)) AS referentiel, CAST(t.colonne AS VARCHAR (128)) AS colonne,
       CAST(t.libelle_colonne AS NVARCHAR (40)) AS libelle_colonne, CAST(t.rang_libelle AS INT) AS rang_libelle,
       CAST(t.modifiable AS INT) AS modifiable, CAST(t.marque_annexe AS INT) AS marque_annexe
FROM (
    -- ref_compte
    SELECT 'ref_compte' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 1),
        ('libelle_complet', N'Libellé complet', 2, 1, 0),
        ('classe', N'Classe', 3, 1, 0),
        ('niveau', N'Niveau du compte', 4, 1, 0),
        ('compte_parent', N'Compte de rattachement', 5, 1, 0),
        ('porte_actif', N'Suivi par actif', 6, 1, 0),
        ('rubrique_resultat', N'Rubrique du compte de résultat', 7, 1, 0),
        ('source_article', N'Fondement', 91, 1, 0),
        ('reference_id', N'Référence', 122, 1, 0),
        ('employee_par', N'Employée par', 123, 0, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_cycle
    SELECT 'ref_cycle' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 0),
        ('applicabilite', N'Arrêtés concernés', 92, 1, 0),
        ('ordre', N'Ordre', 93, 1, 0),
        ('employee_par', N'Employée par', 123, 0, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_phase
    SELECT 'ref_phase' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 0),
        ('niveau', N'Niveau', 8, 1, 0),
        ('ordre', N'Ordre', 93, 1, 0),
        ('employee_par', N'Employée par', 123, 0, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_question
    SELECT 'ref_question' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('enonce', N'Énoncé', 9, 1, 0),
        ('type_reponse', N'Type de réponse', 10, 1, 0),
        ('statut', N'Statut', 11, 1, 0),
        ('options', N'Réponses possibles', 12, 1, 0),
        ('doc_attendu', N'Document attendu', 13, 1, 0),
        ('reference_texte', N'Texte de référence', 14, 1, 0),
        ('niveau_programme', N'Niveau de programme', 15, 1, 0),
        ('sujet_tenue', N'Sujet', 16, 1, 0),
        ('applicabilite', N'Arrêtés concernés', 92, 1, 0),
        ('ordre', N'Ordre', 93, 1, 0),
        ('cycle', N'Cycle', 94, 1, 0),
        ('phase', N'Phase', 95, 1, 0),
        ('obligatoire', N'Obligatoire', 96, 1, 0),
        ('section', N'Section', 97, 1, 0),
        ('en_vigueur_depuis', N'En vigueur depuis', 98, 1, 0),
        ('reference', N'Référence', 122, 1, 0),
        ('employee_par', N'Employée par', 123, 0, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_question_article
    SELECT 'ref_question_article' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('nature', N'Nature', 99, 1, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_article
    SELECT 'ref_article' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('titre', N'Titre', 17, 1, 0),
        ('chapitre', N'Chapitre', 18, 1, 0),
        ('dans_perimetre', N'Dans le périmètre du dossier', 19, 1, 0),
        ('ordre', N'Ordre', 93, 1, 0),
        ('section', N'Section', 97, 1, 0),
        ('intitule', N'Intitulé', 100, 1, 0),
        ('source', N'Source', 101, 1, 0),
        ('norme', N'Norme', 102, 1, 0),
        ('employee_par', N'Employée par', 123, 0, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_reference
    SELECT 'ref_reference' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('lu_sur_piece', N'Lu sur la pièce', 20, 1, 1),
        ('page_piece', N'Page de la pièce', 21, 1, 1),
        ('piece_reference', N'Pièce de référence', 22, 1, 0),
        ('abroge_le', N'Abrogé le', 23, 1, 0),
        ('abroge_par', N'Abrogé par', 24, 1, 0),
        ('intitule', N'Intitulé', 100, 0, 1),
        ('norme', N'Norme', 102, 1, 1),
        ('genre', N'Genre', 103, 1, 1),
        ('citation', N'Citation', 104, 0, 1),
        ('lu_le', N'Lu le', 105, 1, 1),
        ('reference', N'Référence', 122, 1, 1),
        ('employee_par', N'Employée par', 123, 0, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_norme
    SELECT 'ref_norme' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle_court', N'Nom court', 25, 1, 1),
        ('libelle_complet', N'Nom complet', 26, 1, 1),
        ('autorite', N'Autorité', 27, 1, 1),
        ('acte_agrement', N'Acte d’agrément', 28, 1, 1),
        ('date_application', N'Date d’application', 29, 1, 1),
        ('edition', N'Édition', 30, 1, 1),
        ('piece_au_dossier', N'Pièce au dossier', 31, 1, 1),
        ('en_vigueur', N'En vigueur', 32, 1, 1),
        ('abroge_par', N'Abrogée par', 33, 1, 1),
        ('applicable_presentation', N'Applicable à la mission de présentation', 34, 1, 1),
        ('note', N'Note', 106, 1, 0),
        ('employee_par', N'Employée par', 123, 0, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- modele_feuille
    SELECT 'modele_feuille' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 0),
        ('standard', N'Modèle standard', 35, 1, 0),
        ('nom_fichier', N'Fichier', 36, 1, 0),
        ('chemin_coffre', N'Emplacement du fichier', 37, 1, 0),
        ('empreinte_sha256', N'Empreinte du fichier', 38, 1, 0),
        ('version', N'Version', 39, 1, 0),
        ('objectif', N'Objectif de la feuille', 40, 1, 0),
        ('en_vigueur_depuis', N'En vigueur depuis', 98, 1, 0),
        ('employee_par', N'Employée par', 123, 0, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_question_modele
    SELECT 'ref_question_modele' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- modele_ecriture
    SELECT 'modele_ecriture' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 0),
        ('question_id', N'Question', 41, 1, 0),
        ('compte_num', N'Numéro de compte', 42, 1, 0),
        ('ordre', N'Ordre', 93, 1, 0),
        ('source', N'Source', 101, 1, 0),
        ('sens', N'Sens', 107, 1, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_piece_attendue
    SELECT 'ref_piece_attendue' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 0),
        ('periodicite', N'Périodicité', 43, 1, 0),
        ('racine_declenchante', N'Racine qui la rend attendue', 44, 1, 0),
        ('ordre', N'Ordre', 93, 1, 0),
        ('cycle', N'Cycle', 94, 1, 0),
        ('phase', N'Phase', 95, 1, 0),
        ('obligatoire', N'Obligatoire', 96, 1, 0),
        ('en_vigueur_depuis', N'En vigueur depuis', 98, 1, 0),
        ('employee_par', N'Employée par', 123, 0, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_nature_piece
    SELECT 'ref_nature_piece' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 0),
        ('conservation', N'Conservation', 45, 1, 0),
        ('ordre', N'Ordre', 93, 1, 0),
        ('source', N'Source', 101, 1, 0),
        ('famille', N'Famille', 108, 1, 0),
        ('reference_id', N'Référence', 122, 1, 0),
        ('employee_par', N'Employée par', 123, 0, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_nature_actif
    SELECT 'ref_nature_actif' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 0),
        ('methode', N'Méthode', 46, 1, 0),
        ('expertise_requise', N'Expertise requise', 47, 1, 1),
        ('article', N'Article', 109, 1, 0),
        ('reference_id', N'Référence', 122, 1, 1),
        ('employee_par', N'Employée par', 123, 0, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_contrepartie_estimation
    SELECT 'ref_contrepartie_estimation' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('compte_contrepartie', N'Compte de contrepartie', 48, 1, 0),
        ('article', N'Article', 109, 1, 0),
        ('motif', N'Motif', 110, 1, 0),
        ('reference_id', N'Référence', 122, 1, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_correspondance_plan
    SELECT 'ref_correspondance_plan' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('compte_modele', N'Compte du plan modèle', 49, 1, 0),
        ('motif', N'Motif', 110, 1, 0),
        ('reference_id', N'Référence', 122, 1, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_nature_arrete
    SELECT 'ref_nature_arrete' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 0),
        ('ordre', N'Ordre', 93, 1, 0),
        ('note', N'Note', 106, 1, 0),
        ('employee_par', N'Employée par', 123, 0, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_forme_conclusion
    SELECT 'ref_forme_conclusion' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 0),
        ('favorable', N'Conclusion favorable', 50, 1, 0),
        ('ordre', N'Ordre', 93, 1, 0),
        ('reference_id', N'Référence', 122, 1, 0),
        ('employee_par', N'Employée par', 123, 0, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_role
    SELECT 'ref_role' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 0),
        ('vise', N'Donne un visa', 51, 1, 0),
        ('ordre', N'Ordre', 93, 1, 0),
        ('employee_par', N'Employée par', 123, 0, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- role_nature_visa
    SELECT 'role_nature_visa' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('motif', N'Motif', 110, 1, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_question_reference
    SELECT 'ref_question_reference' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_rubrique_resultat
    SELECT 'ref_rubrique_resultat' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 0),
        ('ordre', N'Ordre', 93, 1, 0),
        ('source', N'Source', 101, 1, 0),
        ('famille', N'Famille', 108, 1, 0),
        ('romain', N'Numéro de la rubrique', 111, 1, 0),
        ('employee_par', N'Employée par', 123, 0, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_ratio
    SELECT 'ref_ratio' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 0),
        ('source_du_seuil', N'Source du seuil', 52, 1, 0),
        ('calculable', N'Calculable', 53, 1, 0),
        ('calcul_a_valider', N'Calcul à valider', 54, 1, 0),
        ('ordre', N'Ordre', 93, 1, 0),
        ('citation', N'Citation', 104, 1, 0),
        ('lu_le', N'Lu le', 105, 1, 0),
        ('note', N'Note', 106, 1, 0),
        ('sens', N'Sens', 107, 1, 0),
        ('article', N'Article', 109, 1, 0),
        ('seuil', N'Seuil', 112, 1, 0),
        ('forme_vehicule', N'Forme du véhicule', 113, 1, 0),
        ('article_cite', N'Article principal', 114, 1, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_categorie_actif_cmf
    SELECT 'ref_categorie_actif_cmf' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 0),
        ('note', N'Note', 106, 1, 0),
        ('racines', N'Racines de comptes', 115, 1, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_obligation_distribution
    SELECT 'ref_obligation_distribution' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 0),
        ('taux', N'Taux', 55, 1, 0),
        ('abattement', N'Abattement', 56, 1, 0),
        ('exercice_de_rattachement', N'Exercice de rattachement', 57, 1, 0),
        ('ordre', N'Ordre', 93, 1, 0),
        ('citation', N'Citation', 104, 1, 0),
        ('lu_le', N'Lu le', 105, 1, 0),
        ('article', N'Article', 109, 1, 0),
        ('article_cite', N'Article principal', 114, 1, 0),
        ('employee_par', N'Employée par', 123, 0, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_ligne_etat
    SELECT 'ref_ligne_etat' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 1),
        ('ordre', N'Ordre', 93, 1, 1),
        ('sens', N'Sens', 107, 1, 1),
        ('article', N'Article', 109, 1, 1),
        ('romain', N'Numéro de la rubrique', 111, 1, 1),
        ('racines', N'Racines de comptes', 115, 1, 1),
        ('type_ligne', N'Type de ligne', 116, 1, 1),
        ('formule', N'Formule', 117, 1, 1),
        ('renvoi', N'Renvoi', 118, 1, 1),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_tableau_annexe
    SELECT 'ref_tableau_annexe' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 1),
        ('source_valeur', N'Origine des valeurs', 58, 1, 0),
        ('cellules', N'Nombre de cellules', 59, 1, 0),
        ('indicatif', N'Indicatif', 60, 1, 1),
        ('principe', N'Porte un principe', 61, 1, 0),
        ('texte_principe', N'Texte du principe', 62, 1, 0),
        ('ordre', N'Ordre', 93, 1, 0),
        ('note', N'Note', 106, 1, 0),
        ('employee_par', N'Employée par', 123, 0, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_livrable
    SELECT 'ref_livrable' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 0),
        ('formats', N'Formats', 63, 1, 0),
        ('produit_etape_6', N'Produit par l’outil', 64, 1, 0),
        ('applicable', N'Arrêtés concernés', 92, 1, 0),
        ('ordre', N'Ordre', 93, 1, 0),
        ('nature', N'Nature', 99, 1, 0),
        ('article', N'Article', 109, 1, 0),
        ('employee_par', N'Employée par', 123, 0, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_ligne_annexe
    SELECT 'ref_ligne_annexe' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 1),
        ('niveau', N'Niveau de la ligne', 65, 1, 1),
        ('signe', N'Signe', 66, 1, 1),
        ('racines_exclues', N'Racines exclues', 67, 1, 1),
        ('globalisable', N'Globalisable', 68, 1, 0),
        ('formule_calcul', N'Formule de calcul', 69, 1, 1),
        ('ordre', N'Ordre', 93, 1, 1),
        ('sens', N'Sens', 107, 1, 1),
        ('racines', N'Racines de comptes', 115, 1, 1),
        ('type_ligne', N'Type de ligne', 116, 1, 1),
        ('formule', N'Formule', 117, 1, 1),
        ('renvoi', N'Renvoi', 118, 1, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_cas_eligibilite
    SELECT 'ref_cas_eligibilite' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 0),
        ('maitrise', N'Maîtrise de la société', 70, 1, 0),
        ('ordre', N'Ordre', 93, 1, 0),
        ('citation', N'Citation', 104, 1, 0),
        ('note', N'Note', 106, 1, 0),
        ('employee_par', N'Employée par', 123, 0, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_cas_immeuble
    SELECT 'ref_cas_immeuble' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 0),
        ('ordre', N'Ordre', 93, 1, 0),
        ('citation', N'Citation', 104, 1, 0),
        ('note', N'Note', 106, 1, 0),
        ('employee_par', N'Employée par', 123, 0, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_droit_reel
    SELECT 'ref_droit_reel' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 0),
        ('ordre', N'Ordre', 93, 1, 0),
        ('citation', N'Citation', 104, 1, 0),
        ('note', N'Note', 106, 1, 0),
        ('employee_par', N'Employée par', 123, 0, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_controle
    SELECT 'ref_controle' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 0),
        ('code', N'Code', 71, 1, 0),
        ('condition_anomalie', N'Condition d’anomalie', 72, 1, 0),
        ('fondement', N'Fondement', 91, 1, 0),
        ('ordre', N'Ordre', 93, 1, 0),
        ('genre', N'Genre', 103, 1, 0),
        ('employee_par', N'Employée par', 123, 0, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_forme_rapport
    SELECT 'ref_forme_rapport' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 0),
        ('exemple', N'Exemple de la NP 2300', 73, 1, 0),
        ('page_np', N'Page de la NP 2300', 74, 1, 0),
        ('intitule', N'Intitulé du rapport', 75, 1, 0),
        ('attestation', N'Attestation', 76, 1, 0),
        ('texte', N'Texte du rapport', 77, 1, 0),
        ('fondement', N'Fondement', 91, 1, 0),
        ('ordre', N'Ordre', 93, 1, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_source_valeur
    SELECT 'ref_source_valeur' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 0),
        ('saisissable', N'Saisie possible', 78, 1, 0),
        ('ordre', N'Ordre', 93, 1, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_ratio_memoire
    SELECT 'ref_ratio_memoire' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 0),
        ('limite_texte', N'Limite du texte', 79, 1, 0),
        ('article_calcul', N'Article du calcul', 80, 1, 0),
        ('dates_respect', N'Dates de respect', 81, 1, 0),
        ('dates_respect_professionnel', N'Dates de respect, OPCI professionnel', 82, 1, 0),
        ('statut_grand_public', N'Statut, OPCI grand public', 83, 1, 0),
        ('fondement_grand_public', N'Fondement, OPCI grand public', 84, 1, 0),
        ('statut_professionnel', N'Statut, OPCI professionnel', 85, 1, 0),
        ('fondement_professionnel', N'Fondement, OPCI professionnel', 86, 1, 0),
        ('valeur_laissee', N'Fixée par', 87, 1, 0),
        ('ordre', N'Ordre', 93, 1, 0),
        ('citation', N'Citation', 104, 1, 0),
        ('lu_le', N'Lu le', 105, 1, 0),
        ('famille', N'Famille', 108, 1, 0),
        ('article', N'Article', 109, 1, 0),
        ('forme_vehicule', N'Forme du véhicule', 113, 1, 0),
        ('article_cite', N'Article principal', 114, 1, 0),
        ('employee_par', N'Employée par', 123, 0, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_ratio_vehicule
    SELECT 'ref_ratio_vehicule' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('piece_id', N'Pièce justificative', 88, 1, 0),
        ('en_vigueur_depuis', N'En vigueur depuis', 98, 1, 0),
        ('source', N'Source', 101, 1, 0),
        ('lu_le', N'Lu le', 105, 1, 0),
        ('motif', N'Motif', 110, 1, 0),
        ('seuil', N'Seuil', 112, 1, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_cycle_compte
    SELECT 'ref_cycle_compte' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('source', N'Source', 101, 1, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_question_compte
    SELECT 'ref_question_compte' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('source', N'Source', 101, 1, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_parametre
    SELECT 'ref_parametre' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 0, 0),
        ('valeur', N'Valeur', 89, 1, 0),
        ('description', N'Description', 90, 0, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
    UNION ALL
    -- ref_sujet_tenue
    SELECT 'ref_sujet_tenue' AS referentiel, v.colonne, v.libelle_colonne, v.rang_libelle, v.modifiable, v.marque_annexe
    FROM (VALUES
        ('libelle', N'Libellé', 1, 1, 0),
        ('ordre', N'Ordre', 93, 1, 0),
        ('employee_par', N'Employée par', 123, 0, 0),
        ('modifie_le', N'Dernière modification', 124, 0, 0),
        ('modifie_par', N'Modifiée par', 125, 0, 0)
    ) v (colonne, libelle_colonne, rang_libelle, modifiable, marque_annexe)
) t;

GO

