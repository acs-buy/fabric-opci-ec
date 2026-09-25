-- ref_rubrique_resultat : 11 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_rubrique_resultat])
BEGIN
    INSERT INTO dbo.[ref_rubrique_resultat] ([code], [romain], [libelle], [famille], [source], [ordre], [modifie_par], [modifie_le]) VALUES
        (N'AUTRE_CHRG',N'VII',N'Autres charges',N'CORPORATE',N'Article 322-2, Autres charges (VII)',N'7',NULL,NULL),
        (N'AUTRE_PROD',N'V',N'Autres produits',N'AUTRE',N'Article 322-2, Autres produits (V)',N'5',NULL,NULL),
        (N'CHRG_FIN',N'IV',N'Charges sur opérations financières',N'FINANCIER',N'Article 322-2, Total IV',N'4',NULL,NULL),
        (N'CHRG_IMMO',N'II',N'Charges de l''activité immobilière',N'IMMOBILIER',N'Article 322-2, Total II, y compris les charges d''emprunt sur les actifs à caractère immobilier',N'2',NULL,NULL),
        (N'FRAIS_GEST',N'VI',N'Frais de gestion et de fonctionnement externes',N'CORPORATE',N'Article 322-2, Frais de gestion et de fonctionnement externes (VI). Article 322-10 pour les frais de gestion. Ce que le candidat nomme les charges corporate de l''OPCI.',N'6',NULL,NULL),
        (N'PMV_MOINS',N'X',N'Moins-values réalisées nettes',N'PMV',N'Article 322-2, Total X, nettes de frais',N'10',NULL,NULL),
        (N'PMV_PLUS',N'IX',N'Plus-values réalisées nettes',N'PMV',N'Article 322-2, Total IX, nettes de frais',N'9',NULL,NULL),
        (N'PROD_FIN',N'III',N'Produits sur opérations financières',N'FINANCIER',N'Article 322-2, Total III',N'3',NULL,NULL),
        (N'PROD_IMMO',N'I',N'Produits de l''activité immobilière',N'IMMOBILIER',N'Article 322-2, Total I',N'1',NULL,NULL),
        (N'REGUL_PMV',N'XI',N'Régularisations sur plus et moins-values réalisées nettes',N'REGULARISATION',N'Article 322-2, Régularisations (XI)',N'11',NULL,NULL),
        (N'REGUL_RES',N'VIII',N'Régularisations sur résultat net',N'REGULARISATION',N'Article 322-2, Régularisations sur résultat net (VIII). Article 113-3 pour le mécanisme correcteur.',N'8',NULL,NULL);
    PRINT 'ref_rubrique_resultat : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_rubrique_resultat : deja chargee, rien a faire.';
GO
