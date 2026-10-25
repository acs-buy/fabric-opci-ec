-- ref_referentiel : 44 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_referentiel])
BEGIN
    INSERT INTO dbo.[ref_referentiel] ([table_nom], [libelle], [ecran_lu], [qui_tient], [ordre], [domaine], [domaine_ordre], [categorie], [categorie_ordre], [rang_categorie], [mode_tenue], [du_cabinet], [colonne_designation], [actions_de_ligne], [action_propre]) VALUES
        (N'modele_ecriture',N'Modèles d''écriture',N'Brouillon d''écritures',N'ASSOCIE',N'12',N'Comptabilité',N'1',N'Écritures types',N'2',N'1',N'TENU',N'1',N'libelle',N'1',NULL),
        (N'modele_feuille',N'Modèles de feuille de travail',N'Feuille des questions',N'ASSOCIE',N'10',N'Programme de travail',N'2',N'Feuilles de travail',N'5',N'1',N'TENU',N'1',N'libelle',N'1',NULL),
        (N'ref_article',N'Articles du règlement et du code',N'Fondement des questions',N'ASSOCIE',N'7',N'Normes et textes',N'6',N'Normes et articles',N'15',N'3',N'TEXTE',N'1',NULL,N'1',NULL),
        (N'ref_cas_eligibilite',N'Cas d''éligibilité des participations',N'Inventaire des filiales, annexe',N'ASSOCIE',N'33',N'Évaluation des actifs',N'3',N'Éligibilité à l’actif',N'9',N'3',N'TEXTE',N'1',N'libelle',N'1',NULL),
        (N'ref_cas_immeuble',N'Cas d''éligibilité d''un immeuble, article R. 214-81',N'Fiche immeuble, inventaire du portefeuille',N'BASE',N'34',N'Évaluation des actifs',N'3',N'Éligibilité à l’actif',N'9',N'1',N'TEXTE',N'1',N'libelle',N'1',NULL),
        (N'ref_categorie_actif_cmf',N'Catégories d''actif du code monétaire',N'Ratios réglementaires',N'ASSOCIE',N'26',N'Arrêté et distribution',N'4',N'Ratios réglementaires',N'11',N'2',N'TEXTE',N'1',N'libelle',N'1',NULL),
        (N'ref_compte',N'Plan de comptes modèle',N'Écritures, balance, rattachements',N'ASSOCIE',N'1',N'Comptabilité',N'1',N'Plan de comptes',N'1',N'1',N'TENU',N'1',N'libelle',N'1',NULL),
        (N'ref_compte_entite',N'Croisement des comptes vers les feuilles',N'Balance, feuilles de travail',N'ASSOCIE',N'2',NULL,NULL,NULL,NULL,NULL,N'TENU',N'0',NULL,N'1',NULL),
        (N'ref_contrepartie_estimation',N'Contreparties d''estimation prescrites',N'Différences d''estimation',N'ASSOCIE',N'16',N'Évaluation des actifs',N'3',N'Méthodes d’évaluation',N'8',N'2',N'TENU',N'1',NULL,N'1',NULL),
        (N'ref_controle',N'Contrôles de cohérence du dossier',N'Tableau de bord des contrôles',N'ASSOCIE',N'36',N'Programme de travail',N'2',N'Contrôles',N'7',N'1',N'TENU',N'1',N'libelle',N'2',NULL),
        (N'ref_correspondance_plan',N'Correspondance des plans comptables',N'Rattachement des comptes des filiales',N'ASSOCIE',N'17',N'Comptabilité',N'1',N'Plan de comptes',N'1',N'2',N'TENU',N'1',NULL,N'1',NULL),
        (N'ref_cycle',N'Cycles de révision',N'Feuilles de travail, Supervision',N'ASSOCIE',N'3',N'Programme de travail',N'2',N'Cycles et phases',N'3',N'1',N'TENU',N'1',N'libelle',N'1',NULL),
        (N'ref_cycle_compte',N'Racines de comptes des cycles',N'Révision : complexité de la balance, comptes d’un cycle, couverture de la balance',N'ASSOCIE',N'41',N'Programme de travail',N'2',N'Cycles et phases',N'3',N'3',N'TENU',N'1',NULL,N'1',NULL),
        (N'ref_droit_reel',N'Droits réels éligibles, article R. 214-82',N'Fiche immeuble, inventaire du portefeuille',N'BASE',N'35',N'Évaluation des actifs',N'3',N'Éligibilité à l’actif',N'9',N'2',N'TEXTE',N'1',N'libelle',N'1',NULL),
        (N'ref_entite',N'Entités du dossier',N'Tous les écrans, tenues au menu Client',N'BASE',N'20',NULL,NULL,NULL,NULL,NULL,N'TENU',N'0',NULL,N'1',NULL),
        (N'ref_forme_conclusion',N'Formes de conclusion',N'Conclusion d''une feuille',N'ASSOCIE',N'19',N'Programme de travail',N'2',N'Feuilles de travail',N'5',N'2',N'TEXTE',N'1',N'libelle',N'1',NULL),
        (N'ref_forme_rapport',N'Formes du rapport de l''expert-comptable, NP 2300 exemples E1 à E4',N'Rapport de l''expert-comptable',N'BASE',N'37',N'Comptes annuels et rapport',N'5',N'Livrables et rapport',N'14',N'2',N'TEXTE',N'1',N'libelle',N'1',NULL),
        (N'ref_ligne_annexe',N'Lignes des tableaux de l''annexe',N'Annexe, menu Livrables',N'ASSOCIE',N'32',N'Comptes annuels et rapport',N'5',N'États financiers et annexe',N'13',N'3',N'TEXTE',N'1',N'libelle',N'1',NULL),
        (N'ref_ligne_etat',N'Lignes des états financiers',N'Comptes annuels, menu Livrables',N'ASSOCIE',N'28',N'Comptes annuels et rapport',N'5',N'États financiers et annexe',N'13',N'1',N'TEXTE',N'1',N'libelle',N'1',NULL),
        (N'ref_livrable',N'Livrables du dossier',N'Menu Livrables',N'ASSOCIE',N'31',N'Comptes annuels et rapport',N'5',N'Livrables et rapport',N'14',N'1',N'TENU',N'1',N'libelle',N'1',NULL),
        (N'ref_nature_actif',N'Natures d''actif',N'Patrimoine, valorisation',N'ASSOCIE',N'15',N'Évaluation des actifs',N'3',N'Méthodes d’évaluation',N'8',N'1',N'TENU',N'1',N'libelle',N'1',NULL),
        (N'ref_nature_arrete',N'Natures d''arrêté',N'Ouverture d''un arrêté',N'ASSOCIE',N'18',N'Arrêté et distribution',N'4',N'Arrêtés',N'10',N'1',N'TENU',N'1',N'libelle',N'1',NULL),
        (N'ref_nature_piece',N'Natures de pièce justificative',N'Coffre, pièces',N'ASSOCIE',N'14',N'Programme de travail',N'2',N'Pièces justificatives',N'6',N'1',N'TENU',N'1',N'libelle',N'1',NULL),
        (N'ref_norme',N'Normes et règlements',N'Références normatives',N'ASSOCIE',N'9',N'Normes et textes',N'6',N'Normes et articles',N'15',N'1',N'TENU',N'1',N'libelle_court',N'1',NULL),
        (N'ref_obligation_distribution',N'Obligations de distribution',N'Sommes distribuables, étape 5',N'ASSOCIE',N'27',N'Arrêté et distribution',N'4',N'Distribution',N'12',N'1',N'TEXTE',N'1',N'libelle',N'1',NULL),
        (N'ref_parametre',N'Paramètres du cabinet',N'Client et Acceptation : espace du client ; Client et Acceptation, Révision : dépôt des classeurs ; Révision : complexité de la balance, dépôt des fichiers',N'ASSOCIE',N'43',N'Organisation du cabinet',N'7',N'Paramètres du cabinet',N'17',N'1',N'TENU',N'1',N'libelle',N'0',NULL),
        (N'ref_phase',N'Phases de la mission',N'Acceptation, Maintien, Planification',N'ASSOCIE',N'4',N'Programme de travail',N'2',N'Cycles et phases',N'3',N'2',N'TENU',N'1',N'libelle',N'1',NULL),
        (N'ref_piece_attendue',N'Pièces attendues',N'Documents attendus, conclusion',N'ASSOCIE',N'13',N'Programme de travail',N'2',N'Pièces justificatives',N'6',N'2',N'TENU',N'1',N'libelle',N'1',NULL),
        (N'ref_question',N'Questions de révision et de mission',N'Feuille des questions, Acceptation, Maintien',N'REVISEUR',N'5',N'Programme de travail',N'2',N'Questions de référence',N'4',N'1',N'TENU',N'1',NULL,N'3',NULL),
        (N'ref_question_article',N'Articles fondant les questions',N'Feuille des questions',N'ASSOCIE',N'6',N'Programme de travail',N'2',N'Questions de référence',N'4',N'2',N'TENU',N'1',NULL,N'1',NULL),
        (N'ref_question_compte',N'Racines de comptes des questions',N'Révision : couverture de la balance',N'ASSOCIE',N'42',N'Programme de travail',N'2',N'Questions de référence',N'4',N'5',N'TENU',N'1',NULL,N'1',NULL),
        (N'ref_question_modele',N'Modèles de feuille des questions',N'Feuille des questions',N'ASSOCIE',N'11',N'Programme de travail',N'2',N'Questions de référence',N'4',N'4',N'TENU',N'1',NULL,N'1',NULL),
        (N'ref_question_reference',N'Références normatives des questions',N'Fondement des questionnaires de mission',N'ASSOCIE',N'23',N'Programme de travail',N'2',N'Questions de référence',N'4',N'3',N'TENU',N'1',NULL,N'1',NULL),
        (N'ref_ratio',N'Ratios réglementaires',N'Ratios de l''étape 5, régularisations',N'ASSOCIE',N'25',N'Arrêté et distribution',N'4',N'Ratios réglementaires',N'11',N'1',N'TEXTE',N'1',N'libelle',N'1',NULL),
        (N'ref_ratio_memoire',N'Limites réglementaires des 6 familles',N'Arrêté, limites réglementaires',N'BASE',N'39',N'Arrêté et distribution',N'4',N'Ratios réglementaires',N'11',N'3',N'TEXTE',N'1',N'libelle',N'1',NULL),
        (N'ref_ratio_vehicule',N'Seuils propres aux véhicules',N'Référentiels, seuils des véhicules',N'ASSOCIE',N'40',N'Arrêté et distribution',N'4',N'Ratios réglementaires',N'11',N'4',N'TENU',N'1',NULL,N'1',N'Enregistrer le seuil du véhicule'),
        (N'ref_reference',N'Références normatives',N'Questionnaires, natures, contreparties',N'ASSOCIE',N'8',N'Normes et textes',N'6',N'Normes et articles',N'15',N'2',N'TENU',N'1',N'reference',N'1',NULL),
        (N'ref_role',N'Rôles de mission',N'Visa, Supervision',N'ASSOCIE',N'21',N'Organisation du cabinet',N'7',N'Rôles et visas',N'16',N'1',N'TENU',N'1',N'libelle',N'1',NULL),
        (N'ref_rubrique_resultat',N'Rubriques du compte de résultat',N'Rationalisation de l''actif net, compte de résultat',N'ASSOCIE',N'24',N'Comptabilité',N'1',N'Plan de comptes',N'1',N'3',N'TEXTE',N'1',N'libelle',N'1',NULL),
        (N'ref_source_valeur',N'Sources d''une valeur actuelle',N'Valorisation, saisie de la valeur retenue',N'BASE',N'38',N'Évaluation des actifs',N'3',N'Méthodes d’évaluation',N'8',N'3',N'TEXTE',N'1',N'libelle',N'1',NULL),
        (N'ref_sujet_tenue',N'Sujets des questions sur la tenue de la comptabilité',N'Référentiels, étape 3',N'ASSOCIE',N'44',N'Programme de travail',N'2',N'Questions de référence',N'4',N'6',N'TENU',N'1',N'libelle',N'1',NULL),
        (N'ref_tableau_annexe',N'Tableaux de l''annexe',N'Annexe, menu Livrables',N'ASSOCIE',N'29',N'Comptes annuels et rapport',N'5',N'États financiers et annexe',N'13',N'2',N'TEXTE',N'1',N'libelle',N'1',NULL),
        (N'role_nature_visa',N'Natures visables par rôle',N'Visa, Supervision',N'ASSOCIE',N'22',N'Organisation du cabinet',N'7',N'Rôles et visas',N'16',N'2',N'TENU',N'1',NULL,N'1',NULL),
        (N'saisie_annexe',N'Saisie de l''annexe',N'Annexe, menu Livrables',N'REVISEUR',N'30',NULL,NULL,NULL,NULL,NULL,N'TENU',N'0',NULL,N'1',NULL);
    PRINT 'ref_referentiel : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_referentiel : deja chargee, rien a faire.';
GO
