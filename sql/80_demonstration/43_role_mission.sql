-- role_mission : 48 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[role_mission])
BEGIN
    SET IDENTITY_INSERT dbo.[role_mission] ON;
    INSERT INTO dbo.[role_mission] ([id], [entite], [role], [personne], [du], [au], [pose_par], [pose_le], [connexion]) VALUES
        (N'1',N'OMEGA-OPCI',N'ASSOCIE',N'installation (personne)',N'2022-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'2',N'OMEGA-SCI-1',N'ASSOCIE',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'3',N'OMEGA-SCI-10',N'ASSOCIE',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'4',N'OMEGA-SCI-11',N'ASSOCIE',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'5',N'OMEGA-SCI-12',N'ASSOCIE',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'6',N'OMEGA-SCI-2',N'ASSOCIE',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'7',N'OMEGA-SCI-3',N'ASSOCIE',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'8',N'OMEGA-SCI-4',N'ASSOCIE',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'9',N'OMEGA-SCI-5',N'ASSOCIE',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'10',N'OMEGA-SCI-6',N'ASSOCIE',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'11',N'OMEGA-SCI-7',N'ASSOCIE',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'12',N'OMEGA-SCI-8',N'ASSOCIE',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'13',N'OMEGA-SCI-9',N'ASSOCIE',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'14',N'OPCI-1',N'ASSOCIE',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'15',N'SCI-NORD',N'ASSOCIE',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'16',N'SIGMA-SCI-2',N'ASSOCIE',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'17',N'SCI-NORD',N'CHEF_MISSION',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'18',N'SIGMA-SCI-2',N'CHEF_MISSION',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'19',N'OMEGA-SCI-9',N'CHEF_MISSION',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'20',N'OPCI-1',N'CHEF_MISSION',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'21',N'OMEGA-SCI-7',N'CHEF_MISSION',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'22',N'OMEGA-SCI-8',N'CHEF_MISSION',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'23',N'OMEGA-SCI-5',N'CHEF_MISSION',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'24',N'OMEGA-SCI-6',N'CHEF_MISSION',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'25',N'OMEGA-SCI-3',N'CHEF_MISSION',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'26',N'OMEGA-SCI-4',N'CHEF_MISSION',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'27',N'OMEGA-SCI-12',N'CHEF_MISSION',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'28',N'OMEGA-SCI-2',N'CHEF_MISSION',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'29',N'OMEGA-SCI-10',N'CHEF_MISSION',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'30',N'OMEGA-SCI-11',N'CHEF_MISSION',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'31',N'OMEGA-OPCI',N'CHEF_MISSION',N'installation (personne)',N'2022-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'32',N'OMEGA-SCI-1',N'CHEF_MISSION',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',N'installation (connexion)'),
        (N'33',N'OMEGA-OPCI',N'PREPARATEUR',N'installation (personne)',N'2022-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',NULL),
        (N'34',N'OMEGA-SCI-10',N'PREPARATEUR',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',NULL),
        (N'35',N'OMEGA-SCI-1',N'PREPARATEUR',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',NULL),
        (N'36',N'OMEGA-SCI-11',N'PREPARATEUR',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',NULL),
        (N'37',N'OMEGA-SCI-12',N'PREPARATEUR',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',NULL),
        (N'38',N'OMEGA-SCI-4',N'PREPARATEUR',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',NULL),
        (N'39',N'OMEGA-SCI-3',N'PREPARATEUR',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',NULL),
        (N'40',N'OMEGA-SCI-2',N'PREPARATEUR',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',NULL),
        (N'41',N'OMEGA-SCI-5',N'PREPARATEUR',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',NULL),
        (N'42',N'OMEGA-SCI-7',N'PREPARATEUR',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',NULL),
        (N'43',N'OMEGA-SCI-6',N'PREPARATEUR',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',NULL),
        (N'44',N'OMEGA-SCI-8',N'PREPARATEUR',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',NULL),
        (N'45',N'OMEGA-SCI-9',N'PREPARATEUR',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',NULL),
        (N'46',N'SIGMA-SCI-2',N'PREPARATEUR',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',NULL),
        (N'47',N'SCI-NORD',N'PREPARATEUR',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',NULL),
        (N'48',N'OPCI-1',N'PREPARATEUR',N'installation (personne)',N'2023-01-01',NULL,N'installation (pose_par)',N'2026-09-06 01:06:05.776',NULL);
    SET IDENTITY_INSERT dbo.[role_mission] OFF;
    PRINT 'role_mission : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'role_mission : deja chargee, rien a faire.';
GO
