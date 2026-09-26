-- emprunt_intragroupe : 12 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[emprunt_intragroupe])
BEGIN
    SET IDENTITY_INSERT dbo.[emprunt_intragroupe] ON;
    INSERT INTO dbo.[emprunt_intragroupe] ([id], [entite_preteuse], [entite_emprunt], [reference], [objet], [code_actif], [montant_initial], [capital_restant], [taux_annuel], [date_versement], [date_echeance], [subordonne], [source]) VALUES
        (N'1',N'OMEGA-OPCI',N'OMEGA-SCI-1',N'EI-01',N'ACQUISITION',N'IMM-101',N'5525000.00',N'5525000.00',N'6.0000',N'2019-01-02',N'2034-01-02',N'0',N'SIMULE : jeu a 12 filiales, 65 pc du prix de revient a 6 pc'),
        (N'2',N'OMEGA-OPCI',N'OMEGA-SCI-10',N'EI-10',N'ACQUISITION',N'IMM-110',N'8190000.00',N'8190000.00',N'6.0000',N'2019-01-02',N'2034-01-02',N'0',N'SIMULE : jeu a 12 filiales, 65 pc du prix de revient a 6 pc'),
        (N'3',N'OMEGA-OPCI',N'OMEGA-SCI-11',N'EI-11',N'ACQUISITION',N'IMM-111',N'3120000.00',N'3120000.00',N'6.0000',N'2019-01-02',N'2034-01-02',N'0',N'SIMULE : jeu a 12 filiales, 65 pc du prix de revient a 6 pc'),
        (N'4',N'OMEGA-OPCI',N'OMEGA-SCI-12',N'EI-12',N'ACQUISITION',N'IMM-112',N'10725000.00',N'10725000.00',N'6.0000',N'2019-01-02',N'2034-01-02',N'0',N'SIMULE : jeu a 12 filiales, 65 pc du prix de revient a 6 pc'),
        (N'5',N'OMEGA-OPCI',N'OMEGA-SCI-2',N'EI-02',N'ACQUISITION',N'IMM-102',N'5850000.00',N'5850000.00',N'6.0000',N'2019-01-02',N'2034-01-02',N'0',N'SIMULE : jeu a 12 filiales, 65 pc du prix de revient a 6 pc'),
        (N'6',N'OMEGA-OPCI',N'OMEGA-SCI-3',N'EI-03',N'ACQUISITION',N'IMM-103',N'4940000.00',N'4940000.00',N'6.0000',N'2019-01-02',N'2034-01-02',N'0',N'SIMULE : jeu a 12 filiales, 65 pc du prix de revient a 6 pc'),
        (N'7',N'OMEGA-OPCI',N'OMEGA-SCI-4',N'EI-04',N'ACQUISITION',N'IMM-104',N'7280000.00',N'7280000.00',N'6.0000',N'2019-01-02',N'2034-01-02',N'0',N'SIMULE : jeu a 12 filiales, 65 pc du prix de revient a 6 pc'),
        (N'8',N'OMEGA-OPCI',N'OMEGA-SCI-5',N'EI-05',N'ACQUISITION',N'IMM-105',N'4095000.00',N'4095000.00',N'6.0000',N'2019-01-02',N'2034-01-02',N'0',N'SIMULE : jeu a 12 filiales, 65 pc du prix de revient a 6 pc'),
        (N'9',N'OMEGA-OPCI',N'OMEGA-SCI-6',N'EI-06',N'ACQUISITION',N'IMM-106',N'9620000.00',N'9620000.00',N'6.0000',N'2019-01-02',N'2034-01-02',N'0',N'SIMULE : jeu a 12 filiales, 65 pc du prix de revient a 6 pc'),
        (N'10',N'OMEGA-OPCI',N'OMEGA-SCI-7',N'EI-07',N'ACQUISITION',N'IMM-107',N'3380000.00',N'3380000.00',N'6.0000',N'2019-01-02',N'2034-01-02',N'0',N'SIMULE : jeu a 12 filiales, 65 pc du prix de revient a 6 pc'),
        (N'11',N'OMEGA-OPCI',N'OMEGA-SCI-8',N'EI-08',N'ACQUISITION',N'IMM-108',N'6760000.00',N'6760000.00',N'6.0000',N'2019-01-02',N'2034-01-02',N'0',N'SIMULE : jeu a 12 filiales, 65 pc du prix de revient a 6 pc'),
        (N'12',N'OMEGA-OPCI',N'OMEGA-SCI-9',N'EI-09',N'ACQUISITION',N'IMM-109',N'5135000.00',N'5135000.00',N'6.0000',N'2019-01-02',N'2034-01-02',N'0',N'SIMULE : jeu a 12 filiales, 65 pc du prix de revient a 6 pc');
    SET IDENTITY_INSERT dbo.[emprunt_intragroupe] OFF;
    PRINT 'emprunt_intragroupe : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'emprunt_intragroupe : deja chargee, rien a faire.';
GO
