-- ref_entite : 16 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_entite])
BEGIN
    INSERT INTO dbo.[ref_entite] ([code], [denomination], [siren], [forme_vehicule], [forme_sociale], [adresse_1], [adresse_2], [code_postal], [ville], [pays], [dirigeant_nom], [dirigeant_qualite], [contact_nom], [contact_courriel], [contact_telephone], [cloture], [modifie_par], [modifie_le], [plan_propre_en_service], [est_client], [periodicite_vl], [cree_le]) VALUES
        (N'OMEGA-OPCI',N'OPCI OMEGA',N'400000001',N'SPPICAV',N'SA',N'12 rue de l''Exemple',N'Bâtiment A',N'75008',N'Paris',N'FR',N'Société de gestion OMEGA',N'societe de gestion',N'Service comptable',N'installation',N'01 99 00 00 01',N'31-12',N'installation',N'2026-09-21 09:38:57.998',N'0',N'1',NULL,N'2026-09-16 07:08:00'),
        (N'OMEGA-SCI-1',N'SCI OMEGA 1',N'400000002',NULL,N'SCI',N'12 rue de l''Exemple',NULL,N'75008',N'Paris',N'FR',N'OPCI OMEGA',N'gerant',N'Service comptable',N'installation',N'01 99 00 00 02',N'31-12',N'installation',N'2026-09-21 09:38:57.998',N'1',N'0',NULL,N'2026-09-06 01:14:21'),
        (N'OMEGA-SCI-10',N'SCI OMEGA 10',NULL,NULL,N'SCI',N'1 rue du Cas Construit',NULL,N'75001',N'Paris',N'FR',N'Gerant',N'GERANT',NULL,NULL,NULL,N'31-12',N'installation',N'2026-09-21 09:38:57.953',N'1',N'0',NULL,N'2026-09-06 01:14:21'),
        (N'OMEGA-SCI-11',N'SCI OMEGA 11',NULL,NULL,N'SCI',N'1 rue du Cas Construit',NULL,N'75001',N'Paris',N'FR',N'Gerant',N'GERANT',NULL,NULL,NULL,N'31-12',N'installation',N'2026-09-21 09:38:57.953',N'1',N'0',NULL,N'2026-09-06 01:14:21'),
        (N'OMEGA-SCI-12',N'OMEGA 12 SIIC',NULL,NULL,N'SA',N'1 rue du Cas Construit',NULL,N'75001',N'Paris',N'FR',N'Gerant',N'GERANT',NULL,NULL,NULL,N'31-12',N'installation',N'2026-09-21 09:38:57.953',N'1',N'0',NULL,N'2026-09-06 01:14:22'),
        (N'OMEGA-SCI-2',N'SCI OMEGA 2',N'400000003',NULL,N'SCI',N'12 rue de l''Exemple',NULL,N'75008',N'Paris',N'FR',N'OPCI OMEGA',N'gerant',N'Service comptable',N'installation',N'01 99 00 00 03',N'31-12',N'installation',N'2026-09-21 09:38:57.998',N'1',N'0',NULL,N'2026-09-06 01:14:22'),
        (N'OMEGA-SCI-3',N'SCI OMEGA 3',N'400000004',NULL,N'SCI',N'12 rue de l''Exemple',NULL,N'75008',N'Paris',N'FR',N'OPCI OMEGA',N'gerant',N'Service comptable',N'installation',N'01 99 00 00 04',N'31-12',N'installation',N'2026-09-21 09:38:57.998',N'1',N'0',NULL,N'2026-09-06 01:14:22'),
        (N'OMEGA-SCI-4',N'SCI OMEGA 4',N'400000005',NULL,N'SCI',N'12 rue de l''Exemple',NULL,N'75008',N'Paris',N'FR',N'OPCI OMEGA',N'gerant',N'Service comptable',N'installation',N'01 99 00 00 05',N'31-12',N'installation',N'2026-09-21 09:38:57.998',N'1',N'0',NULL,N'2026-09-06 01:14:22'),
        (N'OMEGA-SCI-5',N'SCI OMEGA 5',N'400000007',NULL,N'SCI',N'12 rue de l''Exemple',NULL,N'75008',N'Paris',N'FR',N'OPCI OMEGA',N'gerant',N'Service comptable',N'installation',N'01 99 00 00 06',N'31-12',N'installation',N'2026-09-21 09:38:57.998',N'1',N'0',NULL,N'2026-09-06 01:14:22'),
        (N'OMEGA-SCI-6',N'SCI OMEGA 6',NULL,NULL,N'SCI',N'1 rue du Cas Construit',NULL,N'75001',N'Paris',N'FR',N'Gerant',N'GERANT',NULL,NULL,NULL,N'31-12',N'installation',N'2026-09-21 09:38:57.953',N'1',N'0',NULL,N'2026-09-06 01:14:22'),
        (N'OMEGA-SCI-7',N'SCI OMEGA 7',NULL,NULL,N'SCI',N'1 rue du Cas Construit',NULL,N'75001',N'Paris',N'FR',N'Gerant',N'GERANT',NULL,NULL,NULL,N'31-12',N'installation',N'2026-09-21 09:38:57.953',N'1',N'0',NULL,N'2026-09-06 01:14:23'),
        (N'OMEGA-SCI-8',N'SCI OMEGA 8',NULL,NULL,N'SCI',N'1 rue du Cas Construit',NULL,N'75001',N'Paris',N'FR',N'Gerant',N'GERANT',NULL,NULL,NULL,N'31-12',N'installation',N'2026-09-21 09:38:57.953',N'1',N'0',NULL,N'2026-09-06 01:14:23'),
        (N'OMEGA-SCI-9',N'SCI OMEGA 9',NULL,NULL,N'SCI',N'1 rue du Cas Construit',NULL,N'75001',N'Paris',N'FR',N'Gerant',N'GERANT',NULL,NULL,NULL,N'31-12',N'installation',N'2026-09-21 09:38:57.953',N'1',N'0',NULL,N'2026-09-06 01:14:23'),
        (N'OPCI-1',N'OPCI SIGMA',N'500000001',N'SPPICAV',N'SAS',N'4 rue de l''Exemple',N'2e étage',N'59000',N'Lille',N'FR',N'Société de gestion SIGMA',N'societe de gestion',N'Service comptable',N'installation',N'03 53 01 00 01',N'31-12',N'installation',N'2026-09-21 09:38:57.998',N'0',N'1',NULL,N'2026-09-16 07:08:00'),
        (N'SCI-NORD',N'SCI SIGMA NORD',N'500000002',NULL,N'SCI',N'4 rue de l''Exemple',NULL,N'59000',N'Lille',N'FR',N'OPCI SIGMA',N'gerant',N'Service comptable',N'installation',N'03 53 01 00 02',N'31-12',N'installation',N'2026-09-21 09:38:57.998',N'0',N'0',NULL,N'2026-09-19 16:21:02'),
        (N'SIGMA-SCI-2',N'SCI SIGMA 2',N'500000003',NULL,N'SCI',N'4 rue de l''Exemple',NULL,N'59000',N'Lille',N'FR',N'OPCI SIGMA',N'gerant',N'Service comptable',N'installation',N'03 53 01 00 03',N'31-12',N'installation',N'2026-09-21 09:38:57.998',N'0',N'0',NULL,N'2026-09-19 16:21:02');
    PRINT 'ref_entite : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_entite : deja chargee, rien a faire.';
GO
