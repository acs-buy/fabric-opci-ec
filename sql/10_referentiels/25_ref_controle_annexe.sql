-- ref_controle_annexe : 25 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_controle_annexe])
BEGIN
    INSERT INTO dbo.[ref_controle_annexe] ([controle], [article], [libelle], [obstacle]) VALUES
        (N'C333_1_CP',N'333-1',N'total des capitaux propres et bilan P_CP',N'0'),
        (N'C333_1_SD',N'333-1',N'somme des 10 lignes et total des sommes distribuables',N'0'),
        (N'C333_3_AN',N'333-3',N'somme algébrique des lignes et actif net de fin',N'1'),
        (N'C334_7_RESULTAT',N'334-7',N'plus-values et 761, moins-values et 661',N'0'),
        (N'C334_BILAN',N'334-2, 334-3, 334-5, 334-6',N'total du tableau et ligne du bilan actif',N'0'),
        (N'C334_BOUCLAGE',N'334-2, 334-3, 334-5, 334-6',N'Exercice N-1 + augmentations - diminutions + variation - Exercice N, par ligne',N'0'),
        (N'C336_2_BILAN',N'336-2',N'inventaire et postes du bilan',N'0'),
        (N'S332_1_VL',N'332-1',N'valeur liquidative calculée et v_valeur_liquidative',N'0'),
        (N'S333_2_PARTS',N'333-2',N'parts nettes et variation des parts en circulation',N'0'),
        (N'S333_2_REGISTRE',N'333-2',N'montant brut du registre des porteurs et solde du 1021 ou du 1022, quand le compte porte un solde',N'0'),
        (N'S333_3_REPORTS',N'333-3',N'reports et distribution de l''exercice précédent',N'0'),
        (N'S335_10_RESULTAT',N'335-10',N'total et compte de résultat R_TVI',N'0'),
        (N'S335_12_ACOMPTES',N'335-12',N'distributions et acomptes payés (solde du 129)',N'0'),
        (N'S335_12_AFFECTATION',N'335-12',N'sommes affectées et sommes distribuables',N'0'),
        (N'S335_12_DISTRIB_PREC',N'335-12, 333-3',N'distribution de l''exercice N-1 affectée et distribution de l''exercice précédent',N'0'),
        (N'S335_2_BILAN',N'335-2',N'sous-totaux et bilan A_AUTRE_1, A_AUTRE_2',N'0'),
        (N'S335_2_DEPRECIATIONS',N'335-2',N'bouclage des dépréciations',N'0'),
        (N'S335_3_PROVISIONS',N'335-3',N'bouclage des provisions',N'0'),
        (N'S335_4_COMPOSANTES',N'335-4',N'emprunts et leurs composantes',N'0'),
        (N'S335_5_TOTAL',N'335-5',N'colonne Total et bilan P_DET_1',N'0'),
        (N'S335_6_BILAN',N'335-6',N'total et bilan P_DET_5',N'0'),
        (N'S335_8_RESULTAT',N'335-8',N'sous-totaux, total et compte de résultat',N'0'),
        (N'S336_2_ACTIF_NET',N'336-2',N'actif net de v_anr_entite et bilan P_CP',N'0'),
        (N'S336_2_DIFFERENCE',N'336-2',N'différence calculée et v_inventaire_filiales',N'0'),
        (N'S336_2_VUE',N'336-2',N'somme d''une colonne de la vue d''inventaire et poste du bilan',N'0');
    PRINT 'ref_controle_annexe : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_controle_annexe : deja chargee, rien a faire.';
GO
