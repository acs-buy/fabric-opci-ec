CREATE   VIEW dbo.v_ecran_referentiel_valeurs AS
WITH cellule AS (
        -- ref_compte
        SELECT 'ref_compte' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_compte x
        LEFT JOIN dbo.ref_reference rr ON rr.id = x.reference_id
        CROSS APPLY (SELECT CAST(CAST(x.compte AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('libelle', N'Libellé', 1, 7, ISNULL(CAST(x.libelle AS NVARCHAR (MAX)), N'')),
            ('libelle_complet', N'Libellé complet', 2, 7, ISNULL(CAST(x.libelle_complet AS NVARCHAR (MAX)), N'')),
            ('classe', N'Classe', 3, 6, ISNULL(CAST(x.classe AS NVARCHAR (MAX)), N'')),
            ('niveau', N'Niveau du compte', 4, 6, ISNULL(CAST(x.niveau AS NVARCHAR (MAX)), N'')),
            ('compte_parent', N'Compte de rattachement', 5, 12, ISNULL(CAST(x.compte_parent AS NVARCHAR (MAX)), N'')),
            ('porte_actif', N'Suivi par actif', 6, 5, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_compte' AND lv.colonne = 'porte_actif' AND lv.valeur = CAST(x.porte_actif AS NVARCHAR (30))), CAST(x.porte_actif AS NVARCHAR (MAX))), N'')),
            ('rubrique_resultat', N'Rubrique du compte de résultat', 7, 8, ISNULL(CAST(x.rubrique_resultat AS NVARCHAR (MAX)), N'')),
            ('source_article', N'Fondement', 91, 9, ISNULL(CAST(x.source_article AS NVARCHAR (MAX)), N'')),
            ('ecartee_le', N'Écartée le', 119, 7, ISNULL(CONVERT(NVARCHAR (10), x.ecartee_le, 103), N'')),
            ('ecartee_par', N'Écartée par', 120, 7, ISNULL(CAST(x.ecartee_par AS NVARCHAR (MAX)), N'')),
            ('motif_ecart', N'Motif de l’écart', 121, 7, ISNULL(CAST(x.motif_ecart AS NVARCHAR (MAX)), N'')),
            ('reference_id', N'Référence', 122, 9, CASE WHEN x.reference_id IS NULL THEN N'' ELSE CONCAT(rr.norme, N' ', rr.reference) END)
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_cycle
        SELECT 'ref_cycle' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_cycle x
        CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('libelle', N'Libellé', 1, 7, ISNULL(CAST(x.libelle AS NVARCHAR (MAX)), N'')),
            ('applicabilite', N'Arrêtés concernés', 92, 9, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_cycle' AND lv.colonne = 'applicabilite' AND lv.valeur = CAST(x.applicabilite AS NVARCHAR (30))), CAST(x.applicabilite AS NVARCHAR (MAX))), N'')),
            ('ordre', N'Ordre', 93, 5, ISNULL(CAST(x.ordre AS NVARCHAR (MAX)), N'')),
            ('ecartee_le', N'Écartée le', 119, 7, ISNULL(CONVERT(NVARCHAR (10), x.ecartee_le, 103), N'')),
            ('ecartee_par', N'Écartée par', 120, 7, ISNULL(CAST(x.ecartee_par AS NVARCHAR (MAX)), N'')),
            ('motif_ecart', N'Motif de l’écart', 121, 7, ISNULL(CAST(x.motif_ecart AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_phase
        SELECT 'ref_phase' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_phase x
        CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('libelle', N'Libellé', 1, 7, ISNULL(CAST(x.libelle AS NVARCHAR (MAX)), N'')),
            ('niveau', N'Niveau', 8, 6, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_phase' AND lv.colonne = 'niveau' AND lv.valeur = CAST(x.niveau AS NVARCHAR (30))), CAST(x.niveau AS NVARCHAR (MAX))), N'')),
            ('ordre', N'Ordre', 93, 5, ISNULL(CAST(x.ordre AS NVARCHAR (MAX)), N'')),
            ('ecartee_le', N'Écartée le', 119, 7, ISNULL(CONVERT(NVARCHAR (10), x.ecartee_le, 103), N'')),
            ('ecartee_par', N'Écartée par', 120, 7, ISNULL(CAST(x.ecartee_par AS NVARCHAR (MAX)), N'')),
            ('motif_ecart', N'Motif de l’écart', 121, 7, ISNULL(CAST(x.motif_ecart AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_question
        SELECT 'ref_question' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_question x
        CROSS APPLY (SELECT CAST(CAST(x.id AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('enonce', N'Énoncé', 9, 6, ISNULL(CAST(x.enonce AS NVARCHAR (MAX)), N'')),
            ('type_reponse', N'Type de réponse', 10, 7, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_question' AND lv.colonne = 'type_reponse' AND lv.valeur = CAST(x.type_reponse AS NVARCHAR (30))), CAST(x.type_reponse AS NVARCHAR (MAX))), N'')),
            ('statut', N'Statut', 11, 6, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_question' AND lv.colonne = 'statut' AND lv.valeur = CAST(x.statut AS NVARCHAR (30))), CAST(x.statut AS NVARCHAR (MAX))), N'')),
            ('options', N'Réponses possibles', 12, 9, ISNULL(CAST(x.options AS NVARCHAR (MAX)), N'')),
            ('doc_attendu', N'Document attendu', 13, 8, ISNULL(CAST(x.doc_attendu AS NVARCHAR (MAX)), N'')),
            ('reference_texte', N'Texte de référence', 14, 9, ISNULL(CAST(x.reference_texte AS NVARCHAR (MAX)), N'')),
            ('niveau_programme', N'Niveau de programme', 15, 9, ISNULL(CAST(x.niveau_programme AS NVARCHAR (MAX)), N'')),
            ('sujet_tenue', N'Sujet', 16, 5, ISNULL(CAST((SELECT d.libelle FROM dbo.ref_sujet_tenue d WHERE d.code = x.sujet_tenue) AS NVARCHAR (MAX)), N'')),
            ('applicabilite', N'Arrêtés concernés', 92, 9, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_question' AND lv.colonne = 'applicabilite' AND lv.valeur = CAST(x.applicabilite AS NVARCHAR (30))), CAST(x.applicabilite AS NVARCHAR (MAX))), N'')),
            ('ordre', N'Ordre', 93, 5, ISNULL(CAST(x.ordre AS NVARCHAR (MAX)), N'')),
            ('cycle', N'Cycle', 94, 5, ISNULL(CAST(x.cycle AS NVARCHAR (MAX)), N'')),
            ('phase', N'Phase', 95, 5, ISNULL(CAST(x.phase AS NVARCHAR (MAX)), N'')),
            ('obligatoire', N'Obligatoire', 96, 11, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_question' AND lv.colonne = 'obligatoire' AND lv.valeur = CAST(x.obligatoire AS NVARCHAR (30))), CAST(x.obligatoire AS NVARCHAR (MAX))), N'')),
            ('section', N'Section', 97, 7, ISNULL(CAST(x.section AS NVARCHAR (MAX)), N'')),
            ('en_vigueur_depuis', N'En vigueur depuis', 98, 7, ISNULL(CONVERT(NVARCHAR (10), x.en_vigueur_depuis, 103), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_question_article
        SELECT 'ref_question_article' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_question_article x
        CROSS APPLY (SELECT CAST(CONCAT(CAST(x.question_id AS NVARCHAR (200)), N' · ', CAST(x.article AS NVARCHAR (200))) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('nature', N'Nature', 99, 6, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_question_article' AND lv.colonne = 'nature' AND lv.valeur = CAST(x.nature AS NVARCHAR (30))), CAST(x.nature AS NVARCHAR (MAX))), N'')),
            ('ecartee_le', N'Écartée le', 119, 7, ISNULL(CONVERT(NVARCHAR (10), x.ecartee_le, 103), N'')),
            ('ecartee_par', N'Écartée par', 120, 7, ISNULL(CAST(x.ecartee_par AS NVARCHAR (MAX)), N'')),
            ('motif_ecart', N'Motif de l’écart', 121, 7, ISNULL(CAST(x.motif_ecart AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_article
        SELECT 'ref_article' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_article x
        CROSS APPLY (SELECT CAST(CAST(x.article AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('titre', N'Titre', 17, 5, ISNULL(CAST(x.titre AS NVARCHAR (MAX)), N'')),
            ('chapitre', N'Chapitre', 18, 8, ISNULL(CAST(x.chapitre AS NVARCHAR (MAX)), N'')),
            ('dans_perimetre', N'Dans le périmètre du dossier', 19, 9, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_article' AND lv.colonne = 'dans_perimetre' AND lv.valeur = CAST(x.dans_perimetre AS NVARCHAR (30))), CAST(x.dans_perimetre AS NVARCHAR (MAX))), N'')),
            ('ordre', N'Ordre', 93, 5, ISNULL(CAST(x.ordre AS NVARCHAR (MAX)), N'')),
            ('section', N'Section', 97, 7, ISNULL(CAST(x.section AS NVARCHAR (MAX)), N'')),
            ('intitule', N'Intitulé', 100, 8, ISNULL(CAST(x.intitule AS NVARCHAR (MAX)), N'')),
            ('source', N'Source', 101, 6, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_article' AND lv.colonne = 'source' AND lv.valeur = CAST(x.source AS NVARCHAR (30))), CAST(x.source AS NVARCHAR (MAX))), N'')),
            ('norme', N'Norme', 102, 5, ISNULL(CAST(x.norme AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_reference
        SELECT 'ref_reference' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_reference x
        CROSS APPLY (SELECT CAST(CAST(x.id AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('lu_sur_piece', N'Lu sur la pièce', 20, 5, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_reference' AND lv.colonne = 'lu_sur_piece' AND lv.valeur = CAST(x.lu_sur_piece AS NVARCHAR (30))), CAST(x.lu_sur_piece AS NVARCHAR (MAX))), N'')),
            ('page_piece', N'Page de la pièce', 21, 5, ISNULL(CAST(x.page_piece AS NVARCHAR (MAX)), N'')),
            ('piece_reference', N'Pièce de référence', 22, 9, ISNULL(CAST(x.piece_reference AS NVARCHAR (MAX)), N'')),
            ('abroge_le', N'Abrogé le', 23, 6, ISNULL(CONVERT(NVARCHAR (10), x.abroge_le, 103), N'')),
            ('abroge_par', N'Abrogé par', 24, 6, ISNULL(CAST(x.abroge_par AS NVARCHAR (MAX)), N'')),
            ('intitule', N'Intitulé', 100, 8, ISNULL(CAST(x.intitule AS NVARCHAR (MAX)), N'')),
            ('genre', N'Genre', 103, 5, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_reference' AND lv.colonne = 'genre' AND lv.valeur = CAST(x.genre AS NVARCHAR (30))), CAST(x.genre AS NVARCHAR (MAX))), N'')),
            ('citation', N'Citation', 104, 8, ISNULL(CAST(x.citation AS NVARCHAR (MAX)), N'')),
            ('lu_le', N'Lu le', 105, 2, ISNULL(CONVERT(NVARCHAR (10), x.lu_le, 103), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_norme
        SELECT 'ref_norme' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_norme x
        CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('libelle_court', N'Nom court', 25, 5, ISNULL(CAST(x.libelle_court AS NVARCHAR (MAX)), N'')),
            ('libelle_complet', N'Nom complet', 26, 7, ISNULL(CAST(x.libelle_complet AS NVARCHAR (MAX)), N'')),
            ('autorite', N'Autorité', 27, 8, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_norme' AND lv.colonne = 'autorite' AND lv.valeur = CAST(x.autorite AS NVARCHAR (30))), CAST(x.autorite AS NVARCHAR (MAX))), N'')),
            ('acte_agrement', N'Acte d’agrément', 28, 10, ISNULL(CAST(x.acte_agrement AS NVARCHAR (MAX)), N'')),
            ('date_application', N'Date d’application', 29, 13, ISNULL(CAST(x.date_application AS NVARCHAR (MAX)), N'')),
            ('edition', N'Édition', 30, 7, ISNULL(CAST(x.edition AS NVARCHAR (MAX)), N'')),
            ('piece_au_dossier', N'Pièce au dossier', 31, 7, ISNULL(CAST(x.piece_au_dossier AS NVARCHAR (MAX)), N'')),
            ('en_vigueur', N'En vigueur', 32, 7, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_norme' AND lv.colonne = 'en_vigueur' AND lv.valeur = CAST(x.en_vigueur AS NVARCHAR (30))), CAST(x.en_vigueur AS NVARCHAR (MAX))), N'')),
            ('abroge_par', N'Abrogée par', 33, 7, ISNULL(CAST(x.abroge_par AS NVARCHAR (MAX)), N'')),
            ('applicable_presentation', N'Applicable à la mission de présentation', 34, 12, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_norme' AND lv.colonne = 'applicable_presentation' AND lv.valeur = CAST(x.applicable_presentation AS NVARCHAR (30))), CAST(x.applicable_presentation AS NVARCHAR (MAX))), N'')),
            ('note', N'Note', 106, 4, ISNULL(CAST(x.note AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- modele_feuille
        SELECT 'modele_feuille' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.modele_feuille x
        CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('libelle', N'Libellé', 1, 7, ISNULL(CAST(x.libelle AS NVARCHAR (MAX)), N'')),
            ('standard', N'Modèle standard', 35, 8, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'modele_feuille' AND lv.colonne = 'standard' AND lv.valeur = CAST(x.standard AS NVARCHAR (30))), CAST(x.standard AS NVARCHAR (MAX))), N'')),
            ('nom_fichier', N'Fichier', 36, 7, ISNULL(CAST(x.nom_fichier AS NVARCHAR (MAX)), N'')),
            ('chemin_coffre', N'Emplacement du fichier', 37, 11, ISNULL(CAST(x.chemin_coffre AS NVARCHAR (MAX)), N'')),
            ('empreinte_sha256', N'Empreinte du fichier', 38, 9, ISNULL(CAST(x.empreinte_sha256 AS NVARCHAR (MAX)), N'')),
            ('version', N'Version', 39, 7, ISNULL(CAST(x.version AS NVARCHAR (MAX)), N'')),
            ('objectif', N'Objectif de la feuille', 40, 8, ISNULL(CAST(x.objectif AS NVARCHAR (MAX)), N'')),
            ('en_vigueur_depuis', N'En vigueur depuis', 98, 7, ISNULL(CONVERT(NVARCHAR (10), x.en_vigueur_depuis, 103), N'')),
            ('ecartee_le', N'Écartée le', 119, 7, ISNULL(CONVERT(NVARCHAR (10), x.ecartee_le, 103), N'')),
            ('ecartee_par', N'Écartée par', 120, 7, ISNULL(CAST(x.ecartee_par AS NVARCHAR (MAX)), N'')),
            ('motif_ecart', N'Motif de l’écart', 121, 7, ISNULL(CAST(x.motif_ecart AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_question_modele
        SELECT 'ref_question_modele' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_question_modele x
        CROSS APPLY (SELECT CAST(CONCAT(CAST(x.question_id AS NVARCHAR (200)), N' · ', CAST(x.modele_code AS NVARCHAR (200))) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('ecartee_le', N'Écartée le', 119, 7, ISNULL(CONVERT(NVARCHAR (10), x.ecartee_le, 103), N'')),
            ('ecartee_par', N'Écartée par', 120, 7, ISNULL(CAST(x.ecartee_par AS NVARCHAR (MAX)), N'')),
            ('motif_ecart', N'Motif de l’écart', 121, 7, ISNULL(CAST(x.motif_ecart AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- modele_ecriture
        SELECT 'modele_ecriture' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.modele_ecriture x
        CROSS APPLY (SELECT CAST(CAST(x.id AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('libelle', N'Libellé', 1, 7, ISNULL(CAST(x.libelle AS NVARCHAR (MAX)), N'')),
            ('compte_num', N'Numéro de compte', 42, 6, ISNULL(CAST(x.compte_num AS NVARCHAR (MAX)), N'')),
            ('source', N'Source', 101, 6, ISNULL(CAST(x.source AS NVARCHAR (MAX)), N'')),
            ('sens', N'Sens', 107, 4, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'modele_ecriture' AND lv.colonne = 'sens' AND lv.valeur = CAST(x.sens AS NVARCHAR (30))), CAST(x.sens AS NVARCHAR (MAX))), N'')),
            ('ecartee_le', N'Écartée le', 119, 7, ISNULL(CONVERT(NVARCHAR (10), x.ecartee_le, 103), N'')),
            ('ecartee_par', N'Écartée par', 120, 7, ISNULL(CAST(x.ecartee_par AS NVARCHAR (MAX)), N'')),
            ('motif_ecart', N'Motif de l’écart', 121, 7, ISNULL(CAST(x.motif_ecart AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_piece_attendue
        SELECT 'ref_piece_attendue' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_piece_attendue x
        CROSS APPLY (SELECT CAST(CAST(x.id AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('libelle', N'Libellé', 1, 7, ISNULL(CAST(x.libelle AS NVARCHAR (MAX)), N'')),
            ('periodicite', N'Périodicité', 43, 11, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_piece_attendue' AND lv.colonne = 'periodicite' AND lv.valeur = CAST(x.periodicite AS NVARCHAR (30))), CAST(x.periodicite AS NVARCHAR (MAX))), N'')),
            ('racine_declenchante', N'Racine qui la rend attendue', 44, 8, ISNULL(CAST(x.racine_declenchante AS NVARCHAR (MAX)), N'')),
            ('obligatoire', N'Obligatoire', 96, 11, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_piece_attendue' AND lv.colonne = 'obligatoire' AND lv.valeur = CAST(x.obligatoire AS NVARCHAR (30))), CAST(x.obligatoire AS NVARCHAR (MAX))), N'')),
            ('en_vigueur_depuis', N'En vigueur depuis', 98, 7, ISNULL(CONVERT(NVARCHAR (10), x.en_vigueur_depuis, 103), N'')),
            ('ecartee_le', N'Écartée le', 119, 7, ISNULL(CONVERT(NVARCHAR (10), x.ecartee_le, 103), N'')),
            ('ecartee_par', N'Écartée par', 120, 7, ISNULL(CAST(x.ecartee_par AS NVARCHAR (MAX)), N'')),
            ('motif_ecart', N'Motif de l’écart', 121, 7, ISNULL(CAST(x.motif_ecart AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_nature_piece
        SELECT 'ref_nature_piece' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_nature_piece x
        LEFT JOIN dbo.ref_reference rr ON rr.id = x.reference_id
        CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('libelle', N'Libellé', 1, 7, ISNULL(CAST(x.libelle AS NVARCHAR (MAX)), N'')),
            ('conservation', N'Conservation', 45, 12, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_nature_piece' AND lv.colonne = 'conservation' AND lv.valeur = CAST(x.conservation AS NVARCHAR (30))), CAST(x.conservation AS NVARCHAR (MAX))), N'')),
            ('ordre', N'Ordre', 93, 5, ISNULL(CAST(x.ordre AS NVARCHAR (MAX)), N'')),
            ('source', N'Source', 101, 6, ISNULL(CAST(x.source AS NVARCHAR (MAX)), N'')),
            ('famille', N'Famille', 108, 7, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_nature_piece' AND lv.colonne = 'famille' AND lv.valeur = CAST(x.famille AS NVARCHAR (30))), CAST(x.famille AS NVARCHAR (MAX))), N'')),
            ('ecartee_le', N'Écartée le', 119, 7, ISNULL(CONVERT(NVARCHAR (10), x.ecartee_le, 103), N'')),
            ('ecartee_par', N'Écartée par', 120, 7, ISNULL(CAST(x.ecartee_par AS NVARCHAR (MAX)), N'')),
            ('motif_ecart', N'Motif de l’écart', 121, 7, ISNULL(CAST(x.motif_ecart AS NVARCHAR (MAX)), N'')),
            ('reference_id', N'Référence', 122, 9, CASE WHEN x.reference_id IS NULL THEN N'' ELSE CONCAT(rr.norme, N' ', rr.reference) END)
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_nature_actif
        SELECT 'ref_nature_actif' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_nature_actif x
        LEFT JOIN dbo.ref_reference rr ON rr.id = x.reference_id
        CROSS APPLY (SELECT CAST(CAST(x.nature AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('libelle', N'Libellé', 1, 7, ISNULL(CAST(x.libelle AS NVARCHAR (MAX)), N'')),
            ('methode', N'Méthode', 46, 7, ISNULL(CAST(x.methode AS NVARCHAR (MAX)), N'')),
            ('expertise_requise', N'Expertise requise', 47, 9, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_nature_actif' AND lv.colonne = 'expertise_requise' AND lv.valeur = CAST(x.expertise_requise AS NVARCHAR (30))), CAST(x.expertise_requise AS NVARCHAR (MAX))), N'')),
            ('article', N'Article', 109, 7, ISNULL(CAST(x.article AS NVARCHAR (MAX)), N'')),
            ('ecartee_le', N'Écartée le', 119, 7, ISNULL(CONVERT(NVARCHAR (10), x.ecartee_le, 103), N'')),
            ('ecartee_par', N'Écartée par', 120, 7, ISNULL(CAST(x.ecartee_par AS NVARCHAR (MAX)), N'')),
            ('motif_ecart', N'Motif de l’écart', 121, 7, ISNULL(CAST(x.motif_ecart AS NVARCHAR (MAX)), N'')),
            ('reference_id', N'Référence', 122, 9, CASE WHEN x.reference_id IS NULL THEN N'' ELSE CONCAT(rr.norme, N' ', rr.reference) END)
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_contrepartie_estimation
        SELECT 'ref_contrepartie_estimation' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_contrepartie_estimation x
        LEFT JOIN dbo.ref_reference rr ON rr.id = x.reference_id
        CROSS APPLY (SELECT CAST(CAST(x.compte_estimation AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('compte_contrepartie', N'Compte de contrepartie', 48, 12, ISNULL(CAST(x.compte_contrepartie AS NVARCHAR (MAX)), N'')),
            ('article', N'Article', 109, 7, ISNULL(CAST(x.article AS NVARCHAR (MAX)), N'')),
            ('motif', N'Motif', 110, 5, ISNULL(CAST(x.motif AS NVARCHAR (MAX)), N'')),
            ('ecartee_le', N'Écartée le', 119, 7, ISNULL(CONVERT(NVARCHAR (10), x.ecartee_le, 103), N'')),
            ('ecartee_par', N'Écartée par', 120, 7, ISNULL(CAST(x.ecartee_par AS NVARCHAR (MAX)), N'')),
            ('motif_ecart', N'Motif de l’écart', 121, 7, ISNULL(CAST(x.motif_ecart AS NVARCHAR (MAX)), N'')),
            ('reference_id', N'Référence', 122, 9, CASE WHEN x.reference_id IS NULL THEN N'' ELSE CONCAT(rr.norme, N' ', rr.reference) END)
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_correspondance_plan
        SELECT 'ref_correspondance_plan' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_correspondance_plan x
        LEFT JOIN dbo.ref_reference rr ON rr.id = x.reference_id
        CROSS APPLY (SELECT CAST(CONCAT(CAST(x.norme_source AS NVARCHAR (200)), N' · ', CAST(x.compte_source AS NVARCHAR (200))) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('compte_modele', N'Compte du plan modèle', 49, 6, ISNULL(CAST(x.compte_modele AS NVARCHAR (MAX)), N'')),
            ('motif', N'Motif', 110, 5, ISNULL(CAST(x.motif AS NVARCHAR (MAX)), N'')),
            ('ecartee_le', N'Écartée le', 119, 7, ISNULL(CONVERT(NVARCHAR (10), x.ecartee_le, 103), N'')),
            ('ecartee_par', N'Écartée par', 120, 7, ISNULL(CAST(x.ecartee_par AS NVARCHAR (MAX)), N'')),
            ('motif_ecart', N'Motif de l’écart', 121, 7, ISNULL(CAST(x.motif_ecart AS NVARCHAR (MAX)), N'')),
            ('reference_id', N'Référence', 122, 9, CASE WHEN x.reference_id IS NULL THEN N'' ELSE CONCAT(rr.norme, N' ', rr.reference) END)
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_nature_arrete
        SELECT 'ref_nature_arrete' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_nature_arrete x
        CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('libelle', N'Libellé', 1, 7, ISNULL(CAST(x.libelle AS NVARCHAR (MAX)), N'')),
            ('ordre', N'Ordre', 93, 5, ISNULL(CAST(x.ordre AS NVARCHAR (MAX)), N'')),
            ('note', N'Note', 106, 4, ISNULL(CAST(x.note AS NVARCHAR (MAX)), N'')),
            ('ecartee_le', N'Écartée le', 119, 7, ISNULL(CONVERT(NVARCHAR (10), x.ecartee_le, 103), N'')),
            ('ecartee_par', N'Écartée par', 120, 7, ISNULL(CAST(x.ecartee_par AS NVARCHAR (MAX)), N'')),
            ('motif_ecart', N'Motif de l’écart', 121, 7, ISNULL(CAST(x.motif_ecart AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_forme_conclusion
        SELECT 'ref_forme_conclusion' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_forme_conclusion x
        LEFT JOIN dbo.ref_reference rr ON rr.id = x.reference_id
        CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('favorable', N'Conclusion favorable', 50, 10, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_forme_conclusion' AND lv.colonne = 'favorable' AND lv.valeur = CAST(x.favorable AS NVARCHAR (30))), CAST(x.favorable AS NVARCHAR (MAX))), N'')),
            ('ordre', N'Ordre', 93, 5, ISNULL(CAST(x.ordre AS NVARCHAR (MAX)), N'')),
            ('reference_id', N'Référence', 122, 9, CASE WHEN x.reference_id IS NULL THEN N'' ELSE CONCAT(rr.norme, N' ', rr.reference) END)
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_role
        SELECT 'ref_role' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_role x
        CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('libelle', N'Libellé', 1, 7, ISNULL(CAST(x.libelle AS NVARCHAR (MAX)), N'')),
            ('vise', N'Donne un visa', 51, 5, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_role' AND lv.colonne = 'vise' AND lv.valeur = CAST(x.vise AS NVARCHAR (30))), CAST(x.vise AS NVARCHAR (MAX))), N'')),
            ('ordre', N'Ordre', 93, 5, ISNULL(CAST(x.ordre AS NVARCHAR (MAX)), N'')),
            ('ecartee_le', N'Écartée le', 119, 7, ISNULL(CONVERT(NVARCHAR (10), x.ecartee_le, 103), N'')),
            ('ecartee_par', N'Écartée par', 120, 7, ISNULL(CAST(x.ecartee_par AS NVARCHAR (MAX)), N'')),
            ('motif_ecart', N'Motif de l’écart', 121, 7, ISNULL(CAST(x.motif_ecart AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- role_nature_visa
        SELECT 'role_nature_visa' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.role_nature_visa x
        CROSS APPLY (SELECT CAST(CONCAT(CAST(x.role_code AS NVARCHAR (200)), N' · ', CAST(x.nature AS NVARCHAR (200))) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('motif', N'Motif', 110, 5, ISNULL(CAST(x.motif AS NVARCHAR (MAX)), N'')),
            ('ecartee_le', N'Écartée le', 119, 7, ISNULL(CONVERT(NVARCHAR (10), x.ecartee_le, 103), N'')),
            ('ecartee_par', N'Écartée par', 120, 7, ISNULL(CAST(x.ecartee_par AS NVARCHAR (MAX)), N'')),
            ('motif_ecart', N'Motif de l’écart', 121, 7, ISNULL(CAST(x.motif_ecart AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_question_reference
        SELECT 'ref_question_reference' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_question_reference x
        LEFT JOIN dbo.ref_reference rk ON rk.id = x.reference_id
        CROSS APPLY (SELECT CAST(CONCAT(CAST(x.question_reference AS NVARCHAR (200)), N' · ', CONCAT(rk.norme, N' ', rk.reference)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('ecartee_le', N'Écartée le', 119, 7, ISNULL(CONVERT(NVARCHAR (10), x.ecartee_le, 103), N'')),
            ('ecartee_par', N'Écartée par', 120, 7, ISNULL(CAST(x.ecartee_par AS NVARCHAR (MAX)), N'')),
            ('motif_ecart', N'Motif de l’écart', 121, 7, ISNULL(CAST(x.motif_ecart AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_rubrique_resultat
        SELECT 'ref_rubrique_resultat' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_rubrique_resultat x
        CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('ordre', N'Ordre', 93, 5, ISNULL(CAST(x.ordre AS NVARCHAR (MAX)), N'')),
            ('source', N'Source', 101, 6, ISNULL(CAST(x.source AS NVARCHAR (MAX)), N'')),
            ('famille', N'Famille', 108, 7, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_rubrique_resultat' AND lv.colonne = 'famille' AND lv.valeur = CAST(x.famille AS NVARCHAR (30))), CAST(x.famille AS NVARCHAR (MAX))), N'')),
            ('romain', N'Numéro de la rubrique', 111, 8, ISNULL(CAST(x.romain AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_ratio
        SELECT 'ref_ratio' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_ratio x
        CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('source_du_seuil', N'Source du seuil', 52, 6, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_ratio' AND lv.colonne = 'source_du_seuil' AND lv.valeur = CAST(x.source_du_seuil AS NVARCHAR (30))), CAST(x.source_du_seuil AS NVARCHAR (MAX))), N'')),
            ('calculable', N'Calculable', 53, 10, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_ratio' AND lv.colonne = 'calculable' AND lv.valeur = CAST(x.calculable AS NVARCHAR (30))), CAST(x.calculable AS NVARCHAR (MAX))), N'')),
            ('calcul_a_valider', N'Calcul à valider', 54, 7, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_ratio' AND lv.colonne = 'calcul_a_valider' AND lv.valeur = CAST(x.calcul_a_valider AS NVARCHAR (30))), CAST(x.calcul_a_valider AS NVARCHAR (MAX))), N'')),
            ('ordre', N'Ordre', 93, 5, ISNULL(CAST(x.ordre AS NVARCHAR (MAX)), N'')),
            ('citation', N'Citation', 104, 8, ISNULL(CAST(x.citation AS NVARCHAR (MAX)), N'')),
            ('lu_le', N'Lu le', 105, 2, ISNULL(CONVERT(NVARCHAR (10), x.lu_le, 103), N'')),
            ('note', N'Note', 106, 4, ISNULL(CAST(x.note AS NVARCHAR (MAX)), N'')),
            ('sens', N'Sens', 107, 4, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_ratio' AND lv.colonne = 'sens' AND lv.valeur = CAST(x.sens AS NVARCHAR (30))), CAST(x.sens AS NVARCHAR (MAX))), N'')),
            ('article', N'Article', 109, 7, ISNULL(CAST(x.article AS NVARCHAR (MAX)), N'')),
            ('seuil', N'Seuil', 112, 5, ISNULL(REPLACE(REGEXP_REPLACE(CONVERT(NVARCHAR (50), x.seuil * 100), N'(\.[0-9]*[1-9])0+$|\.0+$', N'\1'), N'.', N',') + NCHAR(160) + N'%', N'')),
            ('forme_vehicule', N'Forme du véhicule', 113, 8, ISNULL(CAST(x.forme_vehicule AS NVARCHAR (MAX)), N'')),
            ('article_cite', N'Article principal', 114, 9, ISNULL(CAST(x.article_cite AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_categorie_actif_cmf
        SELECT 'ref_categorie_actif_cmf' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_categorie_actif_cmf x
        CROSS APPLY (SELECT CAST(CAST(x.rang AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('libelle', N'Libellé', 1, 7, ISNULL(CAST(x.libelle AS NVARCHAR (MAX)), N'')),
            ('note', N'Note', 106, 4, ISNULL(CAST(x.note AS NVARCHAR (MAX)), N'')),
            ('racines', N'Racines de comptes', 115, 7, ISNULL(CAST(x.racines AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_obligation_distribution
        SELECT 'ref_obligation_distribution' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_obligation_distribution x
        CROSS APPLY (SELECT CAST(CAST(x.categorie AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('taux', N'Taux', 55, 4, ISNULL(REPLACE(REGEXP_REPLACE(CONVERT(NVARCHAR (50), x.taux * 100), N'(\.[0-9]*[1-9])0+$|\.0+$', N'\1'), N'.', N',') + NCHAR(160) + N'%', N'')),
            ('abattement', N'Abattement', 56, 10, ISNULL(REPLACE(REGEXP_REPLACE(CONVERT(NVARCHAR (50), x.abattement * 100), N'(\.[0-9]*[1-9])0+$|\.0+$', N'\1'), N'.', N',') + NCHAR(160) + N'%', N'')),
            ('exercice_de_rattachement', N'Exercice de rattachement', 57, 12, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_obligation_distribution' AND lv.colonne = 'exercice_de_rattachement' AND lv.valeur = CAST(x.exercice_de_rattachement AS NVARCHAR (30))), CAST(x.exercice_de_rattachement AS NVARCHAR (MAX))), N'')),
            ('ordre', N'Ordre', 93, 5, ISNULL(CAST(x.ordre AS NVARCHAR (MAX)), N'')),
            ('citation', N'Citation', 104, 8, ISNULL(CAST(x.citation AS NVARCHAR (MAX)), N'')),
            ('lu_le', N'Lu le', 105, 2, ISNULL(CONVERT(NVARCHAR (10), x.lu_le, 103), N'')),
            ('article', N'Article', 109, 7, ISNULL(CAST(x.article AS NVARCHAR (MAX)), N'')),
            ('article_cite', N'Article principal', 114, 9, ISNULL(CAST(x.article_cite AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_ligne_etat
        SELECT 'ref_ligne_etat' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_ligne_etat x
        CROSS APPLY (SELECT CAST(CONCAT(CAST(x.etat AS NVARCHAR (200)), N' · ', CAST(x.code AS NVARCHAR (200))) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('ordre', N'Ordre', 93, 5, ISNULL(CAST(x.ordre AS NVARCHAR (MAX)), N'')),
            ('sens', N'Sens', 107, 4, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_ligne_etat' AND lv.colonne = 'sens' AND lv.valeur = CAST(x.sens AS NVARCHAR (30))), CAST(x.sens AS NVARCHAR (MAX))), N'')),
            ('article', N'Article', 109, 7, ISNULL(CAST(x.article AS NVARCHAR (MAX)), N'')),
            ('romain', N'Numéro de la rubrique', 111, 8, ISNULL(CAST(x.romain AS NVARCHAR (MAX)), N'')),
            ('racines', N'Racines de comptes', 115, 7, ISNULL(CAST(x.racines AS NVARCHAR (MAX)), N'')),
            ('type_ligne', N'Type de ligne', 116, 5, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_ligne_etat' AND lv.colonne = 'type_ligne' AND lv.valeur = CAST(x.type_ligne AS NVARCHAR (30))), CAST(x.type_ligne AS NVARCHAR (MAX))), N'')),
            ('formule', N'Formule', 117, 7, ISNULL(CAST(x.formule AS NVARCHAR (MAX)), N'')),
            ('renvoi', N'Renvoi', 118, 6, ISNULL(CAST(x.renvoi AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_tableau_annexe
        SELECT 'ref_tableau_annexe' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_tableau_annexe x
        CROSS APPLY (SELECT CAST(CAST(x.article AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('libelle', N'Libellé', 1, 7, ISNULL(CAST(x.libelle AS NVARCHAR (MAX)), N'')),
            ('source_valeur', N'Origine des valeurs', 58, 7, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_tableau_annexe' AND lv.colonne = 'source_valeur' AND lv.valeur = CAST(x.source_valeur AS NVARCHAR (30))), CAST(x.source_valeur AS NVARCHAR (MAX))), N'')),
            ('cellules', N'Nombre de cellules', 59, 8, ISNULL(CAST(x.cellules AS NVARCHAR (MAX)), N'')),
            ('indicatif', N'Indicatif', 60, 9, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_tableau_annexe' AND lv.colonne = 'indicatif' AND lv.valeur = CAST(x.indicatif AS NVARCHAR (30))), CAST(x.indicatif AS NVARCHAR (MAX))), N'')),
            ('principe', N'Porte un principe', 61, 8, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_tableau_annexe' AND lv.colonne = 'principe' AND lv.valeur = CAST(x.principe AS NVARCHAR (30))), CAST(x.principe AS NVARCHAR (MAX))), N'')),
            ('texte_principe', N'Texte du principe', 62, 8, ISNULL(CAST(x.texte_principe AS NVARCHAR (MAX)), N'')),
            ('ordre', N'Ordre', 93, 5, ISNULL(CAST(x.ordre AS NVARCHAR (MAX)), N'')),
            ('note', N'Note', 106, 4, ISNULL(CAST(x.note AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_livrable
        SELECT 'ref_livrable' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_livrable x
        CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('libelle', N'Libellé', 1, 7, ISNULL(CAST(x.libelle AS NVARCHAR (MAX)), N'')),
            ('formats', N'Formats', 63, 7, ISNULL(CAST(x.formats AS NVARCHAR (MAX)), N'')),
            ('produit_etape_6', N'Produit par l’outil', 64, 7, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_livrable' AND lv.colonne = 'produit_etape_6' AND lv.valeur = CAST(x.produit_etape_6 AS NVARCHAR (30))), CAST(x.produit_etape_6 AS NVARCHAR (MAX))), N'')),
            ('applicable', N'Arrêtés concernés', 92, 9, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_livrable' AND lv.colonne = 'applicable' AND lv.valeur = CAST(x.applicable AS NVARCHAR (30))), CAST(x.applicable AS NVARCHAR (MAX))), N'')),
            ('ordre', N'Ordre', 93, 5, ISNULL(CAST(x.ordre AS NVARCHAR (MAX)), N'')),
            ('nature', N'Nature', 99, 6, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_livrable' AND lv.colonne = 'nature' AND lv.valeur = CAST(x.nature AS NVARCHAR (30))), CAST(x.nature AS NVARCHAR (MAX))), N'')),
            ('article', N'Article', 109, 7, ISNULL(CAST(x.article AS NVARCHAR (MAX)), N'')),
            ('ecartee_le', N'Écartée le', 119, 7, ISNULL(CONVERT(NVARCHAR (10), x.ecartee_le, 103), N'')),
            ('ecartee_par', N'Écartée par', 120, 7, ISNULL(CAST(x.ecartee_par AS NVARCHAR (MAX)), N'')),
            ('motif_ecart', N'Motif de l’écart', 121, 7, ISNULL(CAST(x.motif_ecart AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_ligne_annexe
        SELECT 'ref_ligne_annexe' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_ligne_annexe x
        CROSS APPLY (SELECT CAST(CONCAT(CAST(x.article AS NVARCHAR (200)), N' · ', CAST(x.code AS NVARCHAR (200))) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('niveau', N'Niveau de la ligne', 65, 6, ISNULL(CAST(x.niveau AS NVARCHAR (MAX)), N'')),
            ('signe', N'Signe', 66, 5, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_ligne_annexe' AND lv.colonne = 'signe' AND lv.valeur = CAST(x.signe AS NVARCHAR (30))), CAST(x.signe AS NVARCHAR (MAX))), N'')),
            ('racines_exclues', N'Racines exclues', 67, 7, ISNULL(CAST(x.racines_exclues AS NVARCHAR (MAX)), N'')),
            ('globalisable', N'Globalisable', 68, 12, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_ligne_annexe' AND lv.colonne = 'globalisable' AND lv.valeur = CAST(x.globalisable AS NVARCHAR (30))), CAST(x.globalisable AS NVARCHAR (MAX))), N'')),
            ('formule_calcul', N'Formule de calcul', 69, 7, ISNULL(CAST(x.formule_calcul AS NVARCHAR (MAX)), N'')),
            ('sens', N'Sens', 107, 4, ISNULL(CAST(x.sens AS NVARCHAR (MAX)), N'')),
            ('racines', N'Racines de comptes', 115, 7, ISNULL(CAST(x.racines AS NVARCHAR (MAX)), N'')),
            ('type_ligne', N'Type de ligne', 116, 5, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_ligne_annexe' AND lv.colonne = 'type_ligne' AND lv.valeur = CAST(x.type_ligne AS NVARCHAR (30))), CAST(x.type_ligne AS NVARCHAR (MAX))), N'')),
            ('formule', N'Formule', 117, 7, ISNULL(CAST(x.formule AS NVARCHAR (MAX)), N'')),
            ('renvoi', N'Renvoi', 118, 6, ISNULL(CAST(x.renvoi AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_cas_eligibilite
        SELECT 'ref_cas_eligibilite' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_cas_eligibilite x
        CROSS APPLY (SELECT CAST(CAST(x.cas AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('libelle', N'Libellé', 1, 7, ISNULL(CAST(x.libelle AS NVARCHAR (MAX)), N'')),
            ('maitrise', N'Maîtrise de la société', 70, 8, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_cas_eligibilite' AND lv.colonne = 'maitrise' AND lv.valeur = CAST(x.maitrise AS NVARCHAR (30))), CAST(x.maitrise AS NVARCHAR (MAX))), N'')),
            ('ordre', N'Ordre', 93, 5, ISNULL(CAST(x.ordre AS NVARCHAR (MAX)), N'')),
            ('citation', N'Citation', 104, 8, ISNULL(CAST(x.citation AS NVARCHAR (MAX)), N'')),
            ('note', N'Note', 106, 4, ISNULL(CAST(x.note AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_cas_immeuble
        SELECT 'ref_cas_immeuble' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_cas_immeuble x
        CROSS APPLY (SELECT CAST(CAST(x.cas AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('libelle', N'Libellé', 1, 7, ISNULL(CAST(x.libelle AS NVARCHAR (MAX)), N'')),
            ('ordre', N'Ordre', 93, 5, ISNULL(CAST(x.ordre AS NVARCHAR (MAX)), N'')),
            ('citation', N'Citation', 104, 8, ISNULL(CAST(x.citation AS NVARCHAR (MAX)), N'')),
            ('note', N'Note', 106, 4, ISNULL(CAST(x.note AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_droit_reel
        SELECT 'ref_droit_reel' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_droit_reel x
        CROSS APPLY (SELECT CAST(CAST(x.droit AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('libelle', N'Libellé', 1, 7, ISNULL(CAST(x.libelle AS NVARCHAR (MAX)), N'')),
            ('ordre', N'Ordre', 93, 5, ISNULL(CAST(x.ordre AS NVARCHAR (MAX)), N'')),
            ('citation', N'Citation', 104, 8, ISNULL(CAST(x.citation AS NVARCHAR (MAX)), N'')),
            ('note', N'Note', 106, 4, ISNULL(CAST(x.note AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_controle
        SELECT 'ref_controle' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_controle x
        CROSS APPLY (SELECT CAST(CAST(x.vue AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('code', N'Code', 71, 4, ISNULL(CAST(x.code AS NVARCHAR (MAX)), N'')),
            ('condition_anomalie', N'Condition d’anomalie', 72, 10, ISNULL(CAST(x.condition_anomalie AS NVARCHAR (MAX)), N'')),
            ('fondement', N'Fondement', 91, 9, ISNULL(CAST(x.fondement AS NVARCHAR (MAX)), N'')),
            ('ordre', N'Ordre', 93, 5, ISNULL(CAST(x.ordre AS NVARCHAR (MAX)), N'')),
            ('genre', N'Genre', 103, 5, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_controle' AND lv.colonne = 'genre' AND lv.valeur = CAST(x.genre AS NVARCHAR (30))), CAST(x.genre AS NVARCHAR (MAX))), N'')),
            ('ecartee_le', N'Écartée le', 119, 7, ISNULL(CONVERT(NVARCHAR (10), x.ecartee_le, 103), N'')),
            ('ecartee_par', N'Écartée par', 120, 7, ISNULL(CAST(x.ecartee_par AS NVARCHAR (MAX)), N'')),
            ('motif_ecart', N'Motif de l’écart', 121, 7, ISNULL(CAST(x.motif_ecart AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_forme_rapport
        SELECT 'ref_forme_rapport' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_forme_rapport x
        CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('libelle', N'Libellé', 1, 7, ISNULL(CAST(x.libelle AS NVARCHAR (MAX)), N'')),
            ('page_np', N'Page de la NP 2300', 74, 4, ISNULL(CAST(x.page_np AS NVARCHAR (MAX)), N'')),
            ('intitule', N'Intitulé du rapport', 75, 8, ISNULL(CAST(x.intitule AS NVARCHAR (MAX)), N'')),
            ('attestation', N'Attestation', 76, 11, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_forme_rapport' AND lv.colonne = 'attestation' AND lv.valeur = CAST(x.attestation AS NVARCHAR (30))), CAST(x.attestation AS NVARCHAR (MAX))), N'')),
            ('texte', N'Texte du rapport', 77, 7, ISNULL(CAST(x.texte AS NVARCHAR (MAX)), N'')),
            ('fondement', N'Fondement', 91, 9, ISNULL(CAST(x.fondement AS NVARCHAR (MAX)), N'')),
            ('ordre', N'Ordre', 93, 5, ISNULL(CAST(x.ordre AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_source_valeur
        SELECT 'ref_source_valeur' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_source_valeur x
        CROSS APPLY (SELECT CAST(CAST(x.source AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('saisissable', N'Saisie possible', 78, 8, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_source_valeur' AND lv.colonne = 'saisissable' AND lv.valeur = CAST(x.saisissable AS NVARCHAR (30))), CAST(x.saisissable AS NVARCHAR (MAX))), N'')),
            ('ordre', N'Ordre', 93, 5, ISNULL(CAST(x.ordre AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_ratio_memoire
        SELECT 'ref_ratio_memoire' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_ratio_memoire x
        CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('limite_texte', N'Limite du texte', 79, 6, ISNULL(CAST(x.limite_texte AS NVARCHAR (MAX)), N'')),
            ('article_calcul', N'Article du calcul', 80, 7, ISNULL(CAST(x.article_calcul AS NVARCHAR (MAX)), N'')),
            ('dates_respect', N'Dates de respect', 81, 7, ISNULL(CAST(x.dates_respect AS NVARCHAR (MAX)), N'')),
            ('dates_respect_professionnel', N'Dates de respect, OPCI professionnel', 82, 13, ISNULL(CAST(x.dates_respect_professionnel AS NVARCHAR (MAX)), N'')),
            ('statut_grand_public', N'Statut, OPCI grand public', 83, 7, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_ratio_memoire' AND lv.colonne = 'statut_grand_public' AND lv.valeur = CAST(x.statut_grand_public AS NVARCHAR (30))), CAST(x.statut_grand_public AS NVARCHAR (MAX))), N'')),
            ('fondement_grand_public', N'Fondement, OPCI grand public', 84, 10, ISNULL(CAST(x.fondement_grand_public AS NVARCHAR (MAX)), N'')),
            ('statut_professionnel', N'Statut, OPCI professionnel', 85, 13, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_ratio_memoire' AND lv.colonne = 'statut_professionnel' AND lv.valeur = CAST(x.statut_professionnel AS NVARCHAR (30))), CAST(x.statut_professionnel AS NVARCHAR (MAX))), N'')),
            ('fondement_professionnel', N'Fondement, OPCI professionnel', 86, 13, ISNULL(CAST(x.fondement_professionnel AS NVARCHAR (MAX)), N'')),
            ('valeur_laissee', N'Fixée par', 87, 5, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_ratio_memoire' AND lv.colonne = 'valeur_laissee' AND lv.valeur = CAST(x.valeur_laissee AS NVARCHAR (30))), CAST(x.valeur_laissee AS NVARCHAR (MAX))), N'')),
            ('ordre', N'Ordre', 93, 5, ISNULL(CAST(x.ordre AS NVARCHAR (MAX)), N'')),
            ('citation', N'Citation', 104, 8, ISNULL(CAST(x.citation AS NVARCHAR (MAX)), N'')),
            ('lu_le', N'Lu le', 105, 2, ISNULL(CONVERT(NVARCHAR (10), x.lu_le, 103), N'')),
            ('famille', N'Famille', 108, 7, ISNULL(CAST(x.famille AS NVARCHAR (MAX)), N'')),
            ('article', N'Article', 109, 7, ISNULL(CAST(x.article AS NVARCHAR (MAX)), N'')),
            ('forme_vehicule', N'Forme du véhicule', 113, 8, ISNULL(CAST(x.forme_vehicule AS NVARCHAR (MAX)), N'')),
            ('article_cite', N'Article principal', 114, 9, ISNULL(CAST(x.article_cite AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_ratio_vehicule
        SELECT 'ref_ratio_vehicule' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_ratio_vehicule x
        LEFT JOIN dbo.ref_ratio_memoire mu ON mu.code = x.code
        CROSS APPLY (SELECT CAST(CONCAT(CAST(x.entite AS NVARCHAR (200)), N' · ', CAST(x.code AS NVARCHAR (200))) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('piece_id', N'Pièce justificative', 88, 13, ISNULL(CAST(x.piece_id AS NVARCHAR (MAX)), N'')),
            ('en_vigueur_depuis', N'En vigueur depuis', 98, 7, ISNULL(CONVERT(NVARCHAR (10), x.en_vigueur_depuis, 103), N'')),
            ('source', N'Source', 101, 6, ISNULL(ISNULL((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_ratio_vehicule' AND lv.colonne = 'source' AND lv.valeur = CAST(x.source AS NVARCHAR (30))), CAST(x.source AS NVARCHAR (MAX))), N'')),
            ('lu_le', N'Lu le', 105, 2, ISNULL(CONVERT(NVARCHAR (10), x.lu_le, 103), N'')),
            ('motif', N'Motif', 110, 5, ISNULL(CAST(x.motif AS NVARCHAR (MAX)), N'')),
            ('seuil', N'Seuil', 112, 5, ISNULL(CASE WHEN mu.unite_seuil = 'TAUX' THEN REPLACE(REGEXP_REPLACE(CONVERT(NVARCHAR (50), x.seuil * 100), N'(\.[0-9]*[1-9])0+$|\.0+$', N'\1'), N'.', N',') + NCHAR(160) + N'%' ELSE REPLACE(REGEXP_REPLACE(CONVERT(NVARCHAR (50), x.seuil), N'(\.[0-9]*[1-9])0+$|\.0+$', N'\1'), N'.', N',') END, N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_cycle_compte
        SELECT 'ref_cycle_compte' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_cycle_compte x
        CROSS APPLY (SELECT CAST(CONCAT(CAST(x.cycle AS NVARCHAR (200)), N' · ', CAST(x.racine AS NVARCHAR (200))) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('source', N'Source', 101, 6, ISNULL(CAST(x.source AS NVARCHAR (MAX)), N'')),
            ('ecartee_le', N'Écartée le', 119, 7, ISNULL(CONVERT(NVARCHAR (10), x.ecartee_le, 103), N'')),
            ('ecartee_par', N'Écartée par', 120, 7, ISNULL(CAST(x.ecartee_par AS NVARCHAR (MAX)), N'')),
            ('motif_ecart', N'Motif de l’écart', 121, 7, ISNULL(CAST(x.motif_ecart AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_question_compte
        SELECT 'ref_question_compte' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_question_compte x
        CROSS APPLY (SELECT CAST(CONCAT(CAST(x.question_id AS NVARCHAR (200)), N' · ', CAST(x.racine AS NVARCHAR (200))) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('source', N'Source', 101, 6, ISNULL(CAST(x.source AS NVARCHAR (MAX)), N'')),
            ('ecartee_le', N'Écartée le', 119, 7, ISNULL(CONVERT(NVARCHAR (10), x.ecartee_le, 103), N'')),
            ('ecartee_par', N'Écartée par', 120, 7, ISNULL(CAST(x.ecartee_par AS NVARCHAR (MAX)), N'')),
            ('motif_ecart', N'Motif de l’écart', 121, 7, ISNULL(CAST(x.motif_ecart AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_parametre
        SELECT 'ref_parametre' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_parametre x
        CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('valeur', N'Valeur', 89, 6, ISNULL(CAST(x.valeur AS NVARCHAR (MAX)), N'')),
            ('description', N'Description', 90, 11, ISNULL(CAST(x.description AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
        UNION ALL
        -- ref_sujet_tenue
        SELECT 'ref_sujet_tenue' AS referentiel, k.cle, v.colonne, v.libelle_colonne, v.rang_libelle, v.mot_entete, v.valeur
        FROM dbo.ref_sujet_tenue x
        CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
        CROSS APPLY (VALUES
            ('ordre', N'Ordre', 93, 5, ISNULL(CAST(x.ordre AS NVARCHAR (MAX)), N''))
        ) v (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
),
toutes AS (
    SELECT c.referentiel, c.cle, l.ligne, c.colonne, c.libelle_colonne, c.rang_libelle, c.mot_entete, c.valeur
    FROM cellule c JOIN dbo.v_ecran_referentiel_lignes l ON l.referentiel = c.referentiel AND l.cle = c.cle
    UNION ALL
    SELECT l.referentiel, l.cle, l.ligne, f.colonne, f.libelle_colonne, f.rang_libelle, f.mot_entete, f.valeur
    FROM dbo.v_ecran_referentiel_lignes l
    CROSS APPLY (VALUES
            (CAST('employee_par' AS VARCHAR (128)), N'Employée par', 123, 8, l.employee_par),
            ('modifie_le', N'Dernière modification', 124, 12, ISNULL(CONVERT(NVARCHAR (10), l.modifie_le, 103), N'importé')),
            ('modifie_par', N'Modifiée par', 125, 8, ISNULL(l.modifie_par, N''))
    ) f (colonne, libelle_colonne, rang_libelle, mot_entete, valeur)
    WHERE f.colonne <> 'employee_par' OR l.referentiel IN ('ref_compte', 'ref_cycle', 'ref_phase', 'ref_question', 'ref_article', 'ref_reference', 'ref_norme', 'modele_feuille', 'ref_piece_attendue', 'ref_nature_piece', 'ref_nature_actif', 'ref_nature_arrete', 'ref_forme_conclusion', 'ref_role', 'ref_rubrique_resultat', 'ref_obligation_distribution', 'ref_tableau_annexe', 'ref_livrable', 'ref_cas_eligibilite', 'ref_cas_immeuble', 'ref_droit_reel', 'ref_controle', 'ref_ratio_memoire', 'ref_sujet_tenue')
),
mesure AS (
    SELECT t.*, nv.n_car, nv.n_mot, nl.n_car AS ligne_car, nl.n_mot AS ligne_mot
    FROM toutes t
    CROSS APPLY (SELECT TRIM(REGEXP_REPLACE(t.valeur, N'[\s\x{0B}\x{1C}-\x{1F}\x{85}\x{A0}\x{1680}\x{2000}-\x{200A}\x{2028}\x{2029}\x{202F}\x{205F}\x{3000}]+', N' ')) AS v) a
    CROSS APPLY (SELECT LEN(a.v) AS n_car, ISNULL((SELECT MAX(LEN(s.value)) FROM STRING_SPLIT(a.v, N' ') s), 0) AS n_mot) nv
    CROSS APPLY (SELECT TRIM(REGEXP_REPLACE(t.ligne, N'[\s\x{0B}\x{1C}-\x{1F}\x{85}\x{A0}\x{1680}\x{2000}-\x{200A}\x{2028}\x{2029}\x{202F}\x{205F}\x{3000}]+', N' ')) AS v) b
    CROSS APPLY (SELECT LEN(b.v) AS n_car, ISNULL((SELECT MAX(LEN(s.value)) FROM STRING_SPLIT(b.v, N' ') s), 0) AS n_mot) nl
),
fenetre AS (
    SELECT m.*, MAX(m.n_car) OVER (PARTITION BY m.referentiel, m.colonne) AS nb,
           MAX(GREATEST(m.n_mot, m.mot_entete)) OVER (PARTITION BY m.referentiel, m.colonne) AS mot,
           MAX(m.ligne_car) OVER (PARTITION BY m.referentiel) AS nb_ligne,
           MAX(m.ligne_mot) OVER (PARTITION BY m.referentiel) AS mot_ligne
    FROM mesure m
)
SELECT CAST(f.referentiel AS VARCHAR (120)) AS referentiel, f.cle, f.ligne, CAST(f.colonne AS VARCHAR (128)) AS colonne,
       CAST(f.libelle_colonne AS NVARCHAR (40)) AS libelle_colonne, CAST(f.rang_libelle AS INT) AS rang_libelle,
       CAST(f.valeur AS NVARCHAR (MAX)) AS valeur,
       CAST(GREATEST(LEAST(300, 12 + 7 * f.nb), 12 + 11 * f.mot) AS INT) AS largeur_colonne,
       CAST(GREATEST(LEAST(300, 12 + 7 * f.nb_ligne), 12 + 11 * GREATEST(f.mot_ligne, 5)) AS INT) AS largeur_ligne
FROM fenetre f;

GO

