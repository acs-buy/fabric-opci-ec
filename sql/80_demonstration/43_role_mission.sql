-- role_mission : 48 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[role_mission])
BEGIN
    INSERT INTO dbo.[role_mission] ([entite], [role], [personne], [du], [au], [pose_par], [pose_le], [connexion]) VALUES
        (N'OMEGA-OPCI',N'ASSOCIE',N'installation',N'2022-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OMEGA-SCI-1',N'ASSOCIE',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OMEGA-SCI-10',N'ASSOCIE',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OMEGA-SCI-11',N'ASSOCIE',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OMEGA-SCI-12',N'ASSOCIE',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OMEGA-SCI-2',N'ASSOCIE',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OMEGA-SCI-3',N'ASSOCIE',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OMEGA-SCI-4',N'ASSOCIE',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OMEGA-SCI-5',N'ASSOCIE',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OMEGA-SCI-6',N'ASSOCIE',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OMEGA-SCI-7',N'ASSOCIE',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OMEGA-SCI-8',N'ASSOCIE',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OMEGA-SCI-9',N'ASSOCIE',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OPCI-1',N'ASSOCIE',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'SCI-NORD',N'ASSOCIE',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'SIGMA-SCI-2',N'ASSOCIE',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'SCI-NORD',N'CHEF_MISSION',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'SIGMA-SCI-2',N'CHEF_MISSION',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OMEGA-SCI-9',N'CHEF_MISSION',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OPCI-1',N'CHEF_MISSION',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OMEGA-SCI-7',N'CHEF_MISSION',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OMEGA-SCI-8',N'CHEF_MISSION',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OMEGA-SCI-5',N'CHEF_MISSION',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OMEGA-SCI-6',N'CHEF_MISSION',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OMEGA-SCI-3',N'CHEF_MISSION',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OMEGA-SCI-4',N'CHEF_MISSION',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OMEGA-SCI-12',N'CHEF_MISSION',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OMEGA-SCI-2',N'CHEF_MISSION',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OMEGA-SCI-10',N'CHEF_MISSION',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OMEGA-SCI-11',N'CHEF_MISSION',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OMEGA-OPCI',N'CHEF_MISSION',N'installation',N'2022-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OMEGA-SCI-1',N'CHEF_MISSION',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',N'installation'),
        (N'OMEGA-OPCI',N'PREPARATEUR',N'installation',N'2022-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',NULL),
        (N'OMEGA-SCI-10',N'PREPARATEUR',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',NULL),
        (N'OMEGA-SCI-1',N'PREPARATEUR',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',NULL),
        (N'OMEGA-SCI-11',N'PREPARATEUR',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',NULL),
        (N'OMEGA-SCI-12',N'PREPARATEUR',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',NULL),
        (N'OMEGA-SCI-4',N'PREPARATEUR',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',NULL),
        (N'OMEGA-SCI-3',N'PREPARATEUR',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',NULL),
        (N'OMEGA-SCI-2',N'PREPARATEUR',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',NULL),
        (N'OMEGA-SCI-5',N'PREPARATEUR',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',NULL),
        (N'OMEGA-SCI-7',N'PREPARATEUR',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',NULL),
        (N'OMEGA-SCI-6',N'PREPARATEUR',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',NULL),
        (N'OMEGA-SCI-8',N'PREPARATEUR',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',NULL),
        (N'OMEGA-SCI-9',N'PREPARATEUR',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',NULL),
        (N'SIGMA-SCI-2',N'PREPARATEUR',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',NULL),
        (N'SCI-NORD',N'PREPARATEUR',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',NULL),
        (N'OPCI-1',N'PREPARATEUR',N'installation',N'2023-01-01',NULL,N'installation',N'2026-09-06 01:06:05.776',NULL);
    PRINT 'role_mission : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'role_mission : deja chargee, rien a faire.';
GO
