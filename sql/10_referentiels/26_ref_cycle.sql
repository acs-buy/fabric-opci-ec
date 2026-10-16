-- ref_cycle : 11 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_cycle])
BEGIN
    INSERT INTO dbo.[ref_cycle] ([code], [libelle], [applicabilite], [ordre], [modifie_par], [modifie_le]) VALUES
        (N'AFFECT',N'Résultat, régularisations et affectation n-1',N'ARRETE_CLOTURE',N'2',N'installation',N'2026-09-06 09:51:29.234'),
        (N'CAPITAL',N'Capital, souscriptions et rachats',N'LES_DEUX',N'1',NULL,NULL),
        (N'CESSIONS',N'Plus et moins-values réalisées',N'LES_DEUX',N'10',NULL,NULL),
        (N'FIN',N'Dépôts et instruments financiers non immobiliers',N'LES_DEUX',N'6',NULL,NULL),
        (N'FRAIS',N'Frais de gestion et de fonctionnement',N'LES_DEUX',N'9',NULL,NULL),
        (N'HB',N'Engagements hors bilan',N'LES_DEUX',N'11',NULL,NULL),
        (N'IMMO',N'Immeubles, terrains, droits réels et crédit-bail',N'LES_DEUX',N'3',NULL,NULL),
        (N'PART',N'Participations immobilières, comptes courants et provisions filiales',N'LES_DEUX',N'4',NULL,NULL),
        (N'TIERS',N'Comptes de tiers, créances locatives et dépréciations',N'LES_DEUX',N'8',NULL,NULL),
        (N'TRESO',N'Comptes financiers et financement',N'LES_DEUX',N'7',NULL,NULL),
        (N'VALO',N'Différences d''estimation',N'LES_DEUX',N'5',NULL,NULL);
    PRINT 'ref_cycle : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_cycle : deja chargee, rien a faire.';
GO
