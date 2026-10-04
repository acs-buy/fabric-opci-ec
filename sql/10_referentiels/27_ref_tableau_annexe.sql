-- ref_tableau_annexe : 28 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_tableau_annexe])
BEGIN
    INSERT INTO dbo.[ref_tableau_annexe] ([article], [libelle], [source_valeur], [cellules], [note], [ordre], [modifie_par], [modifie_le], [indicatif]) VALUES
        (N'331-1',N'Contenu de l''annexe',N'SAISIE',NULL,N'Article 331-1 : l''annexe comporte toutes les informations d''importance significative destinees a completer et a commenter celles donnees par le bilan et le compte de resultat. Une inscription dans l''annexe ne peut se substituer a une inscription au bilan ou au compte de resultat.',N'0',NULL,NULL,N'0'),
        (N'332-1',N'Caractéristiques et activité de l''OPCI',N'SAISIE',N'12',N'Stratégie d''investissement rappelée selon le prospectus, et tableau des 5 derniers exercices : actif net, nombre de parts, valeur liquidative unitaire, distribution unitaire sur résultat de cession et sur résultat net, acomptes compris, capitalisation unitaire, par catégorie de parts.',N'1',NULL,NULL,N'0'),
        (N'332-2',N'Règles et méthodes comptables',N'SAISIE',N'6',NULL,N'2',NULL,NULL,N'0'),
        (N'333-1',N'Décomposition des capitaux propres',N'CALCUL',N'16',N'Ce tableau porte la definition des sommes distribuables : son total (2) est la grandeur que le montant decide de la distribution ne peut pas depasser.',N'13',NULL,NULL,N'0'),
        (N'333-2',N'Évolution du nombre de parts ou actions au cours de l''exercice',N'MIXTE',N'10',N'Les nombres de parts et les montants se calculent des mouvements de porteurs ; la ventilation par categorie se saisit.',N'3',NULL,NULL,N'0'),
        (N'333-3',N'Évolution de l''actif net (= capitaux propres)',N'CALCUL',N'14',N'L''article 333-3 ecrit « actif net (= capitaux propres) », ce qui fonde la definition du script 46.',N'4',NULL,NULL,N'0'),
        (N'334-1',N'Informations relatives aux expositions immobilières',N'SAISIE',NULL,N'Article 334-1 : les informations presentees dans les tableaux de cette section ont pour objectif de refleter les expositions de l''OPCI aux actifs a caractere immobilier a la date de cloture.',N'14',NULL,NULL,N'0'),
        (N'334-2',N'Immeubles en cours, construits ou acquis et droits réels',N'SAISIE',N'8',NULL,N'5',NULL,NULL,N'0'),
        (N'334-3',N'Contrats de crédit-bail',N'MIXTE',NULL,N'Assiette d''origine du contrat, redevances de l''exercice et cumulees, redevances restant a payer et prix d''achat residuel, ventiles par echeance a un an au plus, a plus d''un an et cinq ans au plus, et a plus de cinq ans.',N'15',NULL,NULL,N'0'),
        (N'334-5',N'Parts et actions des sociétés, visées aux 2° et 3° du I de l''article L214-36 du code monétaire et financier',N'SAISIE',N'6',NULL,N'6',NULL,NULL,N'0'),
        (N'334-6',N'Évolution des comptes courants',N'CALCUL',NULL,N'Article 334-6 : le cas echeant, pour les comptes courants, il est precise leur echeance a la cloture de l''exercice.',N'16',NULL,NULL,N'0'),
        (N'334-7',N'Résultat sur plus et moins-values',N'CALCUL',NULL,N'Le tableau croise 11 natures d''actif avec 4 colonnes : plus-values, moins-values, plus et moins-values N, plus et moins-values N-1.',N'17',NULL,NULL,N'0'),
        (N'334-8',N'Exposition liées aux actifs financiers d''OPCI',N'SAISIE',NULL,N'Article 334-8 : les modeles correspondants du reglement relatif aux comptes annuels des OPCCV, soit le reglement ANC 2020-07, s''appliquent. Aucun tableau propre.',N'18',NULL,NULL,N'0'),
        (N'335-1',N'Principe de présentation',N'SAISIE',NULL,NULL,N'19',NULL,NULL,N'1'),
        (N'335-10',N'Frais de gestion et frais de fonctionnement externes',N'CALCUL',N'14',NULL,N'25',NULL,NULL,N'1'),
        (N'335-11',N'Engagements reçus et donnés',N'SAISIE',N'4',NULL,N'10',NULL,NULL,N'1'),
        (N'335-12',N'Tableau d''affectation du résultat',N'CALCUL',N'32',NULL,N'26',NULL,NULL,N'1'),
        (N'335-2',N'Décomposition des créances',N'CALCUL',N'22',NULL,N'20',NULL,NULL,N'1'),
        (N'335-3',N'Détail des provisions pour risques et charges',N'CALCUL',N'8',NULL,N'21',NULL,NULL,N'1'),
        (N'335-4',N'Détail des emprunts',N'SAISIE',N'4',NULL,N'7',NULL,NULL,N'1'),
        (N'335-5',N'Ventilation des emprunts par maturité résiduelle',N'SAISIE',N'4',N'Colonnes : 1, jusqu''à 1 an ; 2, de 1 à 5 ans ; 3, plus de 5 ans ; 4, total.',N'8',NULL,NULL,N'1'),
        (N'335-6',N'Décomposition des dettes',N'CALCUL',N'12',NULL,N'22',NULL,NULL,N'1'),
        (N'335-7',N'Produits et charges de l''activité immobilière',N'SAISIE',N'8',NULL,N'9',NULL,NULL,N'1'),
        (N'335-8',N'Produits et charges sur opérations financières',N'CALCUL',N'36',NULL,N'23',NULL,NULL,N'1'),
        (N'335-9',N'Autres produits et autres charges',N'SAISIE',NULL,NULL,N'24',NULL,NULL,N'1'),
        (N'336-1',N'Principe de présentation',N'SAISIE',NULL,NULL,N'27',NULL,NULL,N'0'),
        (N'336-2',N'Inventaire détaillé des actifs à caractère immobilier',N'MIXTE',NULL,N'Actifs à caractère immobilier, actif par actif, par poste du bilan, avec le tableau des filiales et participations.',N'11',NULL,NULL,N'0'),
        (N'336-3',N'Inventaire détaillé des dépôts et des instruments financiers non immobiliers',N'MIXTE',NULL,N'Dépôts et instruments financiers non immobiliers : libellé, quantité ou nominal, valeur actuelle, devise de cotation, pourcentage de l''actif net.',N'12',NULL,NULL,N'0');
    PRINT 'ref_tableau_annexe : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_tableau_annexe : deja chargee, rien a faire.';
GO
