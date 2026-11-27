-- acceptation_mission : 1 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[acceptation_mission])
BEGIN
    SET IDENTITY_INSERT dbo.[acceptation_mission] ON;
    INSERT INTO dbo.[acceptation_mission] ([id], [entite], [statut], [decision], [motif], [approuve_par], [approuve_le], [cree_par], [cree_le], [cote_questionnaire], [reprise_motif], [message_ecran], [message_ecran_le], [message_ecran_pour]) VALUES
        (N'1',N'OMEGA-OPCI',N'APPROUVE',N'ACCEPTEE',NULL,N'installation (approuve_par)',N'2026-09-06 01:06:59.512',N'installation (cree_par)',N'2026-09-06 01:06:59.2929588',N'ACC-OMEGA-OPCI',NULL,NULL,NULL,NULL);
    SET IDENTITY_INSERT dbo.[acceptation_mission] OFF;
    DECLARE @n INT = (SELECT COUNT(*) FROM dbo.[acceptation_mission]);
    PRINT 'acceptation_mission : ' + CAST(@n AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'acceptation_mission : deja chargee, rien a faire.';
GO
