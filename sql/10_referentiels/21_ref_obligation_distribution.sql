-- ref_obligation_distribution : 3 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_obligation_distribution])
BEGIN
    INSERT INTO dbo.[ref_obligation_distribution] ([categorie], [libelle], [taux], [abattement], [article], [citation], [lu_le], [exercice_de_rattachement], [ordre], [modifie_par], [modifie_le]) VALUES
        (N'EXONEREES',N'Produits de sociétés exonérées, intégralité',N'1.0000',NULL,N'CMF, art. L. 214-69, II, 3°',N'L''integralite de la fraction du resultat distribuable afferent aux produits de certaines societes beneficiant d''exonerations fiscales.',N'2026-09-04',N'EXERCICE',N'3',NULL,NULL),
        (N'PLUS_VALUES',N'Plus-values de cession, 50 % au moins',N'0.5000',NULL,N'CMF, art. L. 214-69, II, 2°',N'A hauteur de 50 % au moins, les plus-values realisees lors de la cession des actifs, au titre de l''exercice suivant.',N'2026-09-04',N'EXERCICE_SUIVANT',N'2',NULL,NULL),
        (N'RESULTAT',N'Résultat distribuable afférent aux produits, 85 % au moins',N'0.8500',N'0.0150',N'CMF, art. L. 214-69, II, 1°',N'A hauteur de 85 % au moins, la fraction du resultat distribuable afferent aux produits, avec un abattement forfaitaire egal a 1,5 % du prix de revient des immeubles.',N'2026-09-04',N'EXERCICE',N'1',NULL,NULL);
    PRINT 'ref_obligation_distribution : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_obligation_distribution : deja chargee, rien a faire.';
GO
