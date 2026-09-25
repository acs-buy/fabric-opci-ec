-- flux_intragroupe : 26 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[flux_intragroupe])
BEGIN
    INSERT INTO dbo.[flux_intragroupe] ([arrete], [nature], [entite_debitrice], [entite_creditrice], [compte_debiteur], [compte_crediteur], [code_actif], [montant], [source]) VALUES
        (N'2025-12-31',N'VENTE_IMMEUBLE',N'OMEGA-SCI-10',N'OMEGA-SCI-11',N'213',N'761',N'IMM-111',N'4656000.00',N'SIMULE : vente d''immeuble entre 2 filiales, au prix de la valeur actuelle retenue a l''arrete. La plus ou moins-value de cession est nette des frais encourus a l''acquisition comme a la cession, article 211-14 du reglement ANC 2021-09, et les frais d''acquisition portes en capital sont annules en contrepartie du resultat de cession, article 211-15.'),
        (N'2025-12-31',N'DIVIDENDE',N'OMEGA-SCI-12',N'OMEGA-OPCI',N'1291',N'73',NULL,N'194736.70',N'SIMULE : dividende distribue par la filiale SIIC a sa mere, 85 % du resultat de l''exercice. Le taux de 85 % est celui de l''article L. 214-69 du CMF applicable a la SPPICAV : son emploi ici pour la filiale est un CHOIX DE JEU. Les comptes 129 sont exclus du resultat lu, faute de quoi le semis se recalculerait sur sa propre distribution.'),
        (N'2025-12-31',N'PRET',N'OMEGA-SCI-1',N'OMEGA-OPCI',N'4551',N'266',N'IMM-101',N'5525000.00',N'DERIVE : dbo.emprunt_intragroupe, encours du pret EI-01'),
        (N'2025-12-31',N'PRET',N'OMEGA-SCI-10',N'OMEGA-OPCI',N'4551',N'266',N'IMM-110',N'8190000.00',N'DERIVE : dbo.emprunt_intragroupe, encours du pret EI-10'),
        (N'2025-12-31',N'PRET',N'OMEGA-SCI-11',N'OMEGA-OPCI',N'4551',N'266',N'IMM-111',N'3120000.00',N'DERIVE : dbo.emprunt_intragroupe, encours du pret EI-11'),
        (N'2025-12-31',N'PRET',N'OMEGA-SCI-12',N'OMEGA-OPCI',N'4551',N'266',N'IMM-112',N'10725000.00',N'DERIVE : dbo.emprunt_intragroupe, encours du pret EI-12'),
        (N'2025-12-31',N'PRET',N'OMEGA-SCI-2',N'OMEGA-OPCI',N'4551',N'266',N'IMM-102',N'5850000.00',N'DERIVE : dbo.emprunt_intragroupe, encours du pret EI-02'),
        (N'2025-12-31',N'PRET',N'OMEGA-SCI-3',N'OMEGA-OPCI',N'4551',N'266',N'IMM-103',N'4940000.00',N'DERIVE : dbo.emprunt_intragroupe, encours du pret EI-03'),
        (N'2025-12-31',N'PRET',N'OMEGA-SCI-4',N'OMEGA-OPCI',N'4551',N'266',N'IMM-104',N'7280000.00',N'DERIVE : dbo.emprunt_intragroupe, encours du pret EI-04'),
        (N'2025-12-31',N'PRET',N'OMEGA-SCI-5',N'OMEGA-OPCI',N'4551',N'266',N'IMM-105',N'4095000.00',N'DERIVE : dbo.emprunt_intragroupe, encours du pret EI-05'),
        (N'2025-12-31',N'PRET',N'OMEGA-SCI-6',N'OMEGA-OPCI',N'4551',N'266',N'IMM-106',N'9620000.00',N'DERIVE : dbo.emprunt_intragroupe, encours du pret EI-06'),
        (N'2025-12-31',N'PRET',N'OMEGA-SCI-7',N'OMEGA-OPCI',N'4551',N'266',N'IMM-107',N'3380000.00',N'DERIVE : dbo.emprunt_intragroupe, encours du pret EI-07'),
        (N'2025-12-31',N'PRET',N'OMEGA-SCI-8',N'OMEGA-OPCI',N'4551',N'266',N'IMM-108',N'6760000.00',N'DERIVE : dbo.emprunt_intragroupe, encours du pret EI-08'),
        (N'2025-12-31',N'PRET',N'OMEGA-SCI-9',N'OMEGA-OPCI',N'4551',N'266',N'IMM-109',N'5135000.00',N'DERIVE : dbo.emprunt_intragroupe, encours du pret EI-09'),
        (N'2025-12-31',N'INTERET',N'OMEGA-SCI-1',N'OMEGA-OPCI',N'623',N'724',N'IMM-101',N'331500.00',N'DERIVE : interets de la periode sur le pret EI-01, taux 6,00 %. Classement IMMOBILIER par Article 322-5 : les charges d''emprunt liees a des actifs immobiliers entrent dans les char'),
        (N'2025-12-31',N'INTERET',N'OMEGA-SCI-10',N'OMEGA-OPCI',N'623',N'724',N'IMM-110',N'491400.00',N'DERIVE : interets de la periode sur le pret EI-10, taux 6,00 %. Classement IMMOBILIER par Article 322-5 : les charges d''emprunt liees a des actifs immobiliers entrent dans les char'),
        (N'2025-12-31',N'INTERET',N'OMEGA-SCI-11',N'OMEGA-OPCI',N'623',N'724',N'IMM-111',N'187200.00',N'DERIVE : interets de la periode sur le pret EI-11, taux 6,00 %. Classement IMMOBILIER par Article 322-5 : les charges d''emprunt liees a des actifs immobiliers entrent dans les char'),
        (N'2025-12-31',N'INTERET',N'OMEGA-SCI-12',N'OMEGA-OPCI',N'623',N'724',N'IMM-112',N'643500.00',N'DERIVE : interets de la periode sur le pret EI-12, taux 6,00 %. Classement IMMOBILIER par Article 322-5 : les charges d''emprunt liees a des actifs immobiliers entrent dans les char'),
        (N'2025-12-31',N'INTERET',N'OMEGA-SCI-2',N'OMEGA-OPCI',N'623',N'724',N'IMM-102',N'351000.00',N'DERIVE : interets de la periode sur le pret EI-02, taux 6,00 %. Classement IMMOBILIER par Article 322-5 : les charges d''emprunt liees a des actifs immobiliers entrent dans les char'),
        (N'2025-12-31',N'INTERET',N'OMEGA-SCI-3',N'OMEGA-OPCI',N'623',N'724',N'IMM-103',N'296400.00',N'DERIVE : interets de la periode sur le pret EI-03, taux 6,00 %. Classement IMMOBILIER par Article 322-5 : les charges d''emprunt liees a des actifs immobiliers entrent dans les char'),
        (N'2025-12-31',N'INTERET',N'OMEGA-SCI-4',N'OMEGA-OPCI',N'623',N'724',N'IMM-104',N'436800.00',N'DERIVE : interets de la periode sur le pret EI-04, taux 6,00 %. Classement IMMOBILIER par Article 322-5 : les charges d''emprunt liees a des actifs immobiliers entrent dans les char'),
        (N'2025-12-31',N'INTERET',N'OMEGA-SCI-5',N'OMEGA-OPCI',N'623',N'724',N'IMM-105',N'245700.00',N'DERIVE : interets de la periode sur le pret EI-05, taux 6,00 %. Classement IMMOBILIER par Article 322-5 : les charges d''emprunt liees a des actifs immobiliers entrent dans les char'),
        (N'2025-12-31',N'INTERET',N'OMEGA-SCI-6',N'OMEGA-OPCI',N'623',N'724',N'IMM-106',N'577200.00',N'DERIVE : interets de la periode sur le pret EI-06, taux 6,00 %. Classement IMMOBILIER par Article 322-5 : les charges d''emprunt liees a des actifs immobiliers entrent dans les char'),
        (N'2025-12-31',N'INTERET',N'OMEGA-SCI-7',N'OMEGA-OPCI',N'623',N'724',N'IMM-107',N'202800.00',N'DERIVE : interets de la periode sur le pret EI-07, taux 6,00 %. Classement IMMOBILIER par Article 322-5 : les charges d''emprunt liees a des actifs immobiliers entrent dans les char'),
        (N'2025-12-31',N'INTERET',N'OMEGA-SCI-8',N'OMEGA-OPCI',N'623',N'724',N'IMM-108',N'405600.00',N'DERIVE : interets de la periode sur le pret EI-08, taux 6,00 %. Classement IMMOBILIER par Article 322-5 : les charges d''emprunt liees a des actifs immobiliers entrent dans les char'),
        (N'2025-12-31',N'INTERET',N'OMEGA-SCI-9',N'OMEGA-OPCI',N'623',N'724',N'IMM-109',N'308100.00',N'DERIVE : interets de la periode sur le pret EI-09, taux 6,00 %. Classement IMMOBILIER par Article 322-5 : les charges d''emprunt liees a des actifs immobiliers entrent dans les char');
    PRINT 'flux_intragroupe : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'flux_intragroupe : deja chargee, rien a faire.';
GO
