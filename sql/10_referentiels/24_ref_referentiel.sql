-- ref_referentiel : 36 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_referentiel])
BEGIN
    INSERT INTO dbo.[ref_referentiel] ([table_nom], [libelle], [ecran_lu], [qui_tient], [ordre]) VALUES
        (N'modele_ecriture',N'Modèles d''écriture',N'Brouillon d''écritures',N'ASSOCIE',N'12'),
        (N'modele_feuille',N'Modèles de feuille de travail',N'Feuille des questions',N'ASSOCIE',N'10'),
        (N'ref_article',N'Articles du règlement et du code',N'Fondement des questions',N'ASSOCIE',N'7'),
        (N'ref_cas_eligibilite',N'Cas d''éligibilité des participations',N'Inventaire des filiales, annexe',N'ASSOCIE',N'33'),
        (N'ref_cas_immeuble',N'Cas d''éligibilité d''un immeuble, article R. 214-81',N'Fiche immeuble, inventaire du portefeuille',N'BASE',N'34'),
        (N'ref_categorie_actif_cmf',N'Catégories d''actif du code monétaire',N'Ratios réglementaires',N'ASSOCIE',N'26'),
        (N'ref_compte',N'Plan de comptes modèle',N'Écritures, balance, rattachements',N'ASSOCIE',N'1'),
        (N'ref_compte_entite',N'Croisement des comptes vers les feuilles',N'Balance, feuilles de travail',N'ASSOCIE',N'2'),
        (N'ref_contrepartie_estimation',N'Contreparties d''estimation prescrites',N'Différences d''estimation',N'ASSOCIE',N'16'),
        (N'ref_controle',N'Registre des contrôles et de leur genre',N'Tableau de bord des contrôles',N'ASSOCIE',N'36'),
        (N'ref_correspondance_plan',N'Correspondance des plans comptables',N'Rattachement des comptes des filiales',N'ASSOCIE',N'17'),
        (N'ref_cycle',N'Cycles de révision',N'Feuilles de travail, Supervision',N'ASSOCIE',N'3'),
        (N'ref_droit_reel',N'Droits réels éligibles, article R. 214-82',N'Fiche immeuble, inventaire du portefeuille',N'BASE',N'35'),
        (N'ref_entite',N'Entités du dossier',N'Tous les écrans, tenues au menu Client',N'BASE',N'20'),
        (N'ref_forme_conclusion',N'Formes de conclusion',N'Conclusion d''une feuille',N'ASSOCIE',N'19'),
        (N'ref_ligne_annexe',N'Lignes des tableaux de l''annexe',N'Annexe, menu Livrables',N'ASSOCIE',N'32'),
        (N'ref_ligne_etat',N'Lignes des états financiers',N'Comptes annuels, menu Livrables',N'ASSOCIE',N'28'),
        (N'ref_livrable',N'Livrables du dossier',N'Menu Livrables',N'ASSOCIE',N'31'),
        (N'ref_nature_actif',N'Natures d''actif',N'Patrimoine, valorisation',N'ASSOCIE',N'15'),
        (N'ref_nature_arrete',N'Natures d''arrêté',N'Ouverture d''un arrêté',N'ASSOCIE',N'18'),
        (N'ref_nature_piece',N'Natures de pièce justificative',N'Coffre, pièces',N'ASSOCIE',N'14'),
        (N'ref_norme',N'Normes et règlements',N'Références normatives',N'ASSOCIE',N'9'),
        (N'ref_obligation_distribution',N'Obligations de distribution',N'Sommes distribuables, étape 5',N'ASSOCIE',N'27'),
        (N'ref_phase',N'Phases de la mission',N'Acceptation, Maintien, Planification',N'ASSOCIE',N'4'),
        (N'ref_piece_attendue',N'Pièces attendues',N'Documents attendus, conclusion',N'ASSOCIE',N'13'),
        (N'ref_question',N'Questions de révision et de mission',N'Feuille des questions, Acceptation, Maintien',N'REVISEUR',N'5'),
        (N'ref_question_article',N'Articles fondant les questions',N'Feuille des questions',N'ASSOCIE',N'6'),
        (N'ref_question_modele',N'Appariement question vers modèle de feuille',N'Feuille des questions',N'ASSOCIE',N'11'),
        (N'ref_question_reference',N'Appariement question vers paragraphe de norme',N'Fondement des questionnaires de mission',N'ASSOCIE',N'23'),
        (N'ref_ratio',N'Ratios réglementaires',N'Ratios de l''étape 5, régularisations',N'ASSOCIE',N'25'),
        (N'ref_reference',N'Références normatives',N'Questionnaires, natures, contreparties',N'ASSOCIE',N'8'),
        (N'ref_role',N'Rôles de mission',N'Visa, Supervision',N'ASSOCIE',N'21'),
        (N'ref_rubrique_resultat',N'Rubriques du compte de résultat',N'Rationalisation de l''actif net, compte de résultat',N'ASSOCIE',N'24'),
        (N'ref_tableau_annexe',N'Tableaux de l''annexe',N'Annexe, menu Livrables',N'ASSOCIE',N'29'),
        (N'role_nature_visa',N'Natures visables par rôle',N'Visa, Supervision',N'ASSOCIE',N'22'),
        (N'saisie_annexe',N'Saisie de l''annexe',N'Annexe, menu Livrables',N'REVISEUR',N'30');
    PRINT 'ref_referentiel : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_referentiel : deja chargee, rien a faire.';
GO
