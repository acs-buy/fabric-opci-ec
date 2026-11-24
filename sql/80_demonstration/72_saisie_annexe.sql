-- saisie_annexe : 3 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[saisie_annexe])
BEGIN
    SET IDENTITY_INSERT dbo.[saisie_annexe] ON;
    INSERT INTO dbo.[saisie_annexe] ([id], [entite], [arrete], [article], [ligne], [colonne], [valeur], [montant], [saisi_par], [saisi_le], [motif], [motif_par], [motif_le]) VALUES
        (N'134',N'OMEGA-OPCI',N'2025-12-31',N'311-1',N'DEVISE',N'1',N'euros',NULL,N'installation (saisi_par)',N'2026-10-07 04:32:55.359',N'devise de comptabilité confirmée le 07/10/2026 : l''euro pour tous les OPCI',N'installation (motif_par)',N'2026-10-07 04:32:55.359'),
        (N'135',N'OMEGA-OPCI',N'2026-06-30',N'311-1',N'DEVISE',N'1',N'euros',NULL,N'installation (saisi_par)',N'2026-10-07 04:32:55.359',N'devise de comptabilité confirmée le 07/10/2026 : l''euro pour tous les OPCI',N'installation (motif_par)',N'2026-10-07 04:32:55.359'),
        (N'136',N'OMEGA-OPCI',N'2026-12-31',N'311-1',N'DEVISE',N'1',N'euros',NULL,N'installation (saisi_par)',N'2026-10-07 04:32:55.359',N'devise de comptabilité confirmée le 07/10/2026 : l''euro pour tous les OPCI',N'installation (motif_par)',N'2026-10-07 04:32:55.359');
    SET IDENTITY_INSERT dbo.[saisie_annexe] OFF;
    PRINT 'saisie_annexe : ' + CAST((SELECT COUNT(*) FROM dbo.[saisie_annexe]) AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'saisie_annexe : deja chargee, rien a faire.';
GO
