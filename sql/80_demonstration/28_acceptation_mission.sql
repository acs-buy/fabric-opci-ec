-- acceptation_mission : 1 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[acceptation_mission])
BEGIN
    INSERT INTO dbo.[acceptation_mission] ([entite], [statut], [decision], [motif], [approuve_par], [approuve_le], [cree_par], [cree_le], [cote_questionnaire], [reprise_motif], [message_ecran], [message_ecran_le], [message_ecran_pour]) VALUES
        (N'OMEGA-OPCI',N'APPROUVE',N'ACCEPTEE',NULL,N'installation',N'2026-09-06 01:06:59.512',N'installation',N'2026-09-06 01:06:59.2929588',N'ACC-OMEGA-OPCI',NULL,N'Approbation refusée : l''acceptation de cette entité est déjà approuvée. Pour la reprendre, passer par la reprise.',N'2026-09-22 20:31:22.568',N'installation');
    PRINT 'acceptation_mission : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'acceptation_mission : deja chargee, rien a faire.';
GO
