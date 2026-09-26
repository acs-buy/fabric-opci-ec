-- evaluation_actif : 1 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[evaluation_actif])
BEGIN
    SET IDENTITY_INSERT dbo.[evaluation_actif] ON;
    INSERT INTO dbo.[evaluation_actif] ([id], [code_actif], [entite], [arrete], [valeur_retenue], [source], [expertise_id], [motif_ecart], [propose_par], [propose_le], [etat], [vise_par], [vise_le], [motif_renvoi], [message_ecran], [message_ecran_le], [message_ecran_pour]) VALUES
        (N'1',N'IMM-201',N'OMEGA-OPCI',N'2025-12-31',N'13000000.00',N'MODELE',NULL,N'SIMULE : modele financier retenu, le marche local n''ayant porte aucune transaction comparable sur l''exercice.',N'installation (propose_par)',N'2026-09-06 01:06:36.035',N'RENVOYE',N'installation (vise_par)',N'2026-09-06 01:06:36.244',N'SIMULE : le modele retenu n''est pas documente. Joindre les hypotheses et la source des taux avant de proposer a nouveau.',NULL,NULL,NULL);
    SET IDENTITY_INSERT dbo.[evaluation_actif] OFF;
    PRINT 'evaluation_actif : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'evaluation_actif : deja chargee, rien a faire.';
GO
