-- ref_colonne_libelle : 51 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_colonne_libelle])
BEGIN
    INSERT INTO dbo.[ref_colonne_libelle] ([vue], [colonne], [libelle], [libelle_court], [aligne], [format], [ordre], [visible], [tri_rang], [tri_sens], [modifie_par], [modifie_le]) VALUES
        (N'v_ecran_differences_synthese',N'arrete',N'Arrêté concerné',N'Arrêté',N'GAUCHE',N'date',N'2',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_differences_synthese',N'article',N'Article du règlement qui fonde l''évaluation',N'Article',N'GAUCHE',NULL,N'4',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_differences_synthese',N'citation_courte',N'Citation courte du texte applicable',N'Texte',N'GAUCHE',NULL,N'10',N'0',NULL,NULL,NULL,NULL),
        (N'v_ecran_differences_synthese',N'difference_estimation',N'Différence d''estimation, valeur actuelle moins comptable',N'Différence',N'DROITE',N'N2',N'8',N'1',N'1',N'DESC',NULL,NULL),
        (N'v_ecran_differences_synthese',N'entite',N'Code de l''entité',N'Entité',N'GAUCHE',NULL,N'1',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_differences_synthese',N'famille',N'Famille d''actif, code technique',N'Code famille',N'GAUCHE',NULL,N'9',N'0',NULL,NULL,NULL,NULL),
        (N'v_ecran_differences_synthese',N'famille_libelle_court',N'Famille d''actif, libellé d''écran',N'Famille',N'GAUCHE',NULL,N'3',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_differences_synthese',N'nombre_actifs',N'Nombre d''actifs de la famille',N'Actifs',N'DROITE',N'N0',N'5',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_differences_synthese',N'valeur_actuelle',N'Valeur actuelle retenue',N'Valeur actuelle',N'DROITE',N'N2',N'7',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_differences_synthese',N'valeur_comptable',N'Valeur comptable, prix de revient',N'Valeur comptable',N'DROITE',N'N2',N'6',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_etat_dossier',N'acceptation_decision',N'Décision portée sur l''acceptation',N'Décision',N'GAUCHE',NULL,N'4',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_etat_dossier',N'acceptation_questions_dues',N'Questions obligatoires attendues',N'Questions dues',N'DROITE',N'N0',N'11',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_etat_dossier',N'acceptation_questions_repondues',N'Questions du questionnaire déjà répondues',N'Questions répondues',N'DROITE',N'N0',N'10',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_etat_dossier',N'acceptation_statut',N'Statut de l''acceptation de mission',N'Acceptation',N'GAUCHE',NULL,N'3',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_etat_dossier',N'arretes_ouverts',N'Nombre d''arrêtés ouverts pour l''entité',N'Arrêtés ouverts',N'DROITE',N'N0',N'6',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_etat_dossier',N'balances_filiales_manquantes',N'Balances de filiales non reçues',N'Balances manquantes',N'DROITE',N'N0',N'13',N'0',NULL,NULL,NULL,NULL),
        (N'v_ecran_etat_dossier',N'chef_de_mission',N'Chef de mission désigné sur l''entité',N'Chef de mission',N'GAUCHE',NULL,N'12',N'0',NULL,NULL,NULL,NULL),
        (N'v_ecran_etat_dossier',N'entite',N'Code de l''entité',N'Entité',N'GAUCHE',NULL,N'1',N'1',N'2',N'ASC',NULL,NULL),
        (N'v_ecran_etat_dossier',N'entite_libelle',N'Dénomination de l''entité',N'Libellé',N'GAUCHE',NULL,N'2',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_etat_dossier',N'expertises_manquantes',N'Actifs sans expertise à la date de l''arrêté',N'Expertises manquantes',N'DROITE',N'N0',N'9',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_etat_dossier',N'feuilles',N'Feuilles de travail du dossier',N'Feuilles',N'DROITE',N'N0',N'7',N'1',N'1',N'DESC',NULL,NULL),
        (N'v_ecran_etat_dossier',N'feuilles_conclues',N'Feuilles dont la conclusion est posée',N'Conclues',N'DROITE',N'N0',N'8',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_etat_dossier',N'maintien_exercice',N'Exercice du dernier maintien approuvé',N'Maintien',N'GAUCHE',NULL,N'5',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_inventaire_referentiel',N'derniere_modification',N'Horodatage de la dernière reprise',N'Dernière reprise',N'GAUCHE',N'datetime',N'7',N'0',NULL,NULL,NULL,NULL),
        (N'v_ecran_inventaire_referentiel',N'etat',N'État du relevé du référentiel',N'État',N'GAUCHE',NULL,N'5',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_inventaire_referentiel',N'libelle',N'Intitulé du référentiel',N'Référentiel',N'GAUCHE',NULL,N'1',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_inventaire_referentiel',N'lignes',N'Nombre de lignes du référentiel',N'Lignes',N'DROITE',N'N0',N'3',N'1',N'1',N'DESC',NULL,NULL),
        (N'v_ecran_inventaire_referentiel',N'lignes_modifiees',N'Lignes reprises au portail depuis l''import',N'Modifiées',N'DROITE',N'N0',N'4',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_inventaire_referentiel',N'qui_tient',N'Rôle qui tient le référentiel',N'Qui tient',N'GAUCHE',NULL,N'2',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_inventaire_referentiel',N'table_nom',N'Nom de la table dans la base',N'Table',N'GAUCHE',NULL,N'6',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_livrables_dus',N'article',N'Texte qui exige le livrable',N'Article',N'GAUCHE',NULL,N'5',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_livrables_dus',N'derniere_version',N'Dernière version produite',N'Version',N'GAUCHE',NULL,N'9',N'0',NULL,NULL,NULL,NULL),
        (N'v_ecran_livrables_dus',N'etape_5_cloturee',N'L''étape d''arrêté est-elle clôturée',N'Étape close',N'CENTRE',NULL,N'6',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_livrables_dus',N'etat',N'État du livrable, en clair',N'État',N'GAUCHE',NULL,N'8',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_livrables_dus',N'libelle',N'Intitulé du livrable',N'Libellé',N'GAUCHE',NULL,N'3',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_livrables_dus',N'livrable',N'Code du livrable',N'Livrable',N'GAUCHE',NULL,N'2',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_livrables_dus',N'nature',N'Nature du livrable, document ou décision',N'Nature',N'GAUCHE',NULL,N'4',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_livrables_dus',N'ordre',N'Rang du livrable dans l''arrêté',N'Ordre',N'DROITE',N'N0',N'1',N'1',N'1',N'ASC',NULL,NULL),
        (N'v_ecran_livrables_dus',N'perime_motif',N'Motif de péremption du livrable',N'Motif de péremption',N'GAUCHE',NULL,N'10',N'0',NULL,NULL,NULL,NULL),
        (N'v_ecran_livrables_dus',N'produit_le',N'Date de production du livrable',N'Produit le',N'GAUCHE',N'date',N'7',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_supervision_cycle',N'a_viser',N'Objets en attente de visa sur le cycle',N'À viser',N'DROITE',N'N0',N'4',N'1',N'2',N'DESC',NULL,NULL),
        (N'v_ecran_supervision_cycle',N'arrete',N'Arrêté concerné',N'Arrêté',N'GAUCHE',N'date',N'2',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_supervision_cycle',N'cycle_affiche',N'Cycle de révision, ou l''arrêté lui-même',N'Cycle',N'GAUCHE',NULL,N'3',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_supervision_cycle',N'cycle_libelle',N'Libellé complet du cycle de révision',N'Libellé du cycle',N'GAUCHE',NULL,N'11',N'0',NULL,NULL,NULL,NULL),
        (N'v_ecran_supervision_cycle',N'decisions',N'Décisions prises, visas et renvois confondus',N'Décisions',N'DROITE',N'N0',N'7',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_supervision_cycle',N'dernier_decideur',N'Personne qui a pris la dernière décision',N'Dernier décideur',N'GAUCHE',NULL,N'9',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_supervision_cycle',N'derniere_decision',N'Horodatage de la dernière décision',N'Dernière décision',N'GAUCHE',N'datetime',N'8',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_supervision_cycle',N'entite',N'Code de l''entité',N'Entité',N'GAUCHE',NULL,N'1',N'1',N'3',N'ASC',NULL,NULL),
        (N'v_ecran_supervision_cycle',N'etat_cycle',N'État du cycle, calculé sur ses objets',N'État',N'GAUCHE',NULL,N'10',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_supervision_cycle',N'renvoyes',N'Objets renvoyés par le décideur',N'Renvoyés',N'DROITE',N'N0',N'6',N'1',NULL,NULL,NULL,NULL),
        (N'v_ecran_supervision_cycle',N'vises',N'Objets visés sur le cycle',N'Visés',N'DROITE',N'N0',N'5',N'1',N'1',N'DESC',NULL,NULL);
    PRINT 'ref_colonne_libelle : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_colonne_libelle : deja chargee, rien a faire.';
GO
