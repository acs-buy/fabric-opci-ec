-- obligation_distribution : 3 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[obligation_distribution])
BEGIN
    SET IDENTITY_INSERT dbo.[obligation_distribution] ON;
    INSERT INTO dbo.[obligation_distribution] ([id], [entite], [exercice], [categorie], [base_calcul], [taux], [montant], [dont_indirect_n_moins_1], [source], [vise_par], [vise_le], [etat], [propose_par], [indirect_saisi_par], [message_ecran], [message_ecran_le], [message_ecran_pour]) VALUES
        (N'5',N'OMEGA-OPCI',N'2025-12-31',N'PLUS_VALUES_50',N'0.00',N'50.00',N'0.00',N'0.00',N'SIMULE : derive du resultat de l''exercice, article L. 214-69 du CMF',N'installation (vise_par)',N'2026-09-06 01:05:55.930',N'VISEE',NULL,NULL,NULL,NULL,NULL),
        (N'6',N'OMEGA-OPCI',N'2025-12-31',N'DIVIDENDES_SIIC_100',N'0.00',N'100.00',N'0.00',N'0.00',N'SIMULE : derive du resultat de l''exercice, article L. 214-69 du CMF',N'installation (vise_par)',N'2026-09-06 01:05:55.930',N'VISEE',NULL,NULL,NULL,NULL,NULL),
        (N'7',N'OMEGA-OPCI',N'2025-12-31',N'REVENUS_85',N'8817978.50',N'85.00',N'7495281.73',N'0.00',N'SIMULE : Resultat distribuable afferent aux produits, resultat net et report a nouveau, 9 365 478,50, diminue de l''abattement de 1,5 % du prix de revient des immeubles detenus directement, 36 500 000,00, soit 547 500,00 ; CMF, art. L. 214-69, II, 1°',N'installation (vise_par)',N'2026-09-06 17:13:45.369',NULL,NULL,NULL,NULL,NULL,NULL);
    SET IDENTITY_INSERT dbo.[obligation_distribution] OFF;
    PRINT 'obligation_distribution : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'obligation_distribution : deja chargee, rien a faire.';
GO
