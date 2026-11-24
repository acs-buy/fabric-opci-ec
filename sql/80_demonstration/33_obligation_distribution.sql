-- obligation_distribution : 3 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[obligation_distribution])
BEGIN
    SET IDENTITY_INSERT dbo.[obligation_distribution] ON;
    INSERT INTO dbo.[obligation_distribution] ([id], [entite], [exercice], [categorie], [base_calcul], [taux], [montant], [dont_indirect_n_moins_1], [source], [vise_par], [vise_le], [etat], [propose_par], [indirect_saisi_par], [message_ecran], [message_ecran_le], [message_ecran_pour]) VALUES
        (N'5',N'OMEGA-OPCI',N'2025-12-31',N'PLUS_VALUES_50',N'0.00',N'50.00',N'0.00',N'0.00',N'SIMULE : derive du resultat de l''exercice, article L. 214-69 du CMF',N'installation (vise_par)',N'2026-09-06 01:05:55.9300000',N'VISEE',NULL,NULL,NULL,NULL,NULL),
        (N'6',N'OMEGA-OPCI',N'2025-12-31',N'DIVIDENDES_SIIC_100',N'0.00',N'100.00',N'0.00',N'0.00',N'SIMULE : derive du resultat de l''exercice, article L. 214-69 du CMF',N'installation (vise_par)',N'2026-09-06 01:05:55.9300000',N'VISEE',NULL,NULL,NULL,NULL,NULL),
        (N'7',N'OMEGA-OPCI',N'2025-12-31',N'REVENUS_85',N'6173143.06',N'85.00',N'5247171.60',N'0.00',N'Part directe 1 930 302,50, frais imputés 59 532,44 (31/12 de N-1 seul), abattement 547 500,00, quote-part des filiales 4 849 873,00 (indicative), au plus le résultat distribuable ; CMF, art. L. 214-69, II, 1°',N'installation (vise_par)',N'2026-09-06 17:13:45.3690000',NULL,NULL,NULL,NULL,NULL,NULL);
    SET IDENTITY_INSERT dbo.[obligation_distribution] OFF;
    PRINT 'obligation_distribution : ' + CAST((SELECT COUNT(*) FROM dbo.[obligation_distribution]) AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'obligation_distribution : deja chargee, rien a faire.';
GO
