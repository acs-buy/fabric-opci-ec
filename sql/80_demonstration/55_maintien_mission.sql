-- maintien_mission : 4 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[maintien_mission])
BEGIN
    INSERT INTO dbo.[maintien_mission] ([id], [entite], [arrete_conclu], [statut], [decision], [motif], [approuve_par], [approuve_le], [cree_par], [cree_le], [cote_questionnaire], [reprise_motif], [message_ecran], [message_ecran_le], [message_ecran_pour]) VALUES
        (N'1',N'OMEGA-OPCI',N'2025-12-31',N'APPROUVE',N'MAINTENU',NULL,N'installation',N'2026-09-06 01:06:59.929',N'installation',N'2026-09-06 01:06:59.8504316',N'MTN-OMEGA-OPCI-2025',NULL,NULL,NULL,NULL),
        (N'2',N'OMEGA-OPCI',N'2022-12-31',N'APPROUVE',N'MAINTENU',N'SIMULE : mise en etat de l''historique 2022-2024, script 148. Exercice clos, mission maintenue.',N'installation',N'2026-09-06 16:18:48.304',N'installation',N'2026-09-06 16:18:48.3039491',N'MTN-OMEGA-OPCI-2022',NULL,NULL,NULL,NULL),
        (N'3',N'OMEGA-OPCI',N'2023-12-31',N'APPROUVE',N'MAINTENU',N'SIMULE : mise en etat de l''historique 2022-2024, script 148. Exercice clos, mission maintenue.',N'installation',N'2026-09-06 16:18:48.304',N'installation',N'2026-09-06 16:18:48.3039491',N'MTN-OMEGA-OPCI-2023',NULL,NULL,NULL,NULL),
        (N'4',N'OMEGA-OPCI',N'2024-12-31',N'APPROUVE',N'MAINTENU',N'SIMULE : mise en etat de l''historique 2022-2024, script 148. Exercice clos, mission maintenue.',N'installation',N'2026-09-06 16:18:48.304',N'installation',N'2026-09-06 16:18:48.3039491',N'MTN-OMEGA-OPCI-2024',NULL,NULL,NULL,NULL);
    PRINT 'maintien_mission : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'maintien_mission : deja chargee, rien a faire.';
GO
