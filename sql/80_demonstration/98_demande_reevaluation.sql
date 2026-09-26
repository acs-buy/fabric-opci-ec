-- demande_reevaluation : 1 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[demande_reevaluation])
BEGIN
    SET IDENTITY_INSERT dbo.[demande_reevaluation] ON;
    INSERT INTO dbo.[demande_reevaluation] ([id], [entite], [arrete], [etat], [posee_par], [posee_le], [motif_demande], [lot_id], [compte_rendu], [actifs_traites], [actifs_bloques], [servie_le], [servie_par]) VALUES
        (N'1',N'OMEGA-SCI-1',N'2025-12-31',N'FAITE',N'installation (posee_par)',N'2026-09-06 01:06:39.053',N'SIMULE : le lot est perime par une expertise intercalaire, la generation est reprise.',N'65',N'SIMULE : 1 actif traite, 0 bloque. La derniere expertise dont la date de valeur ne depasse pas l''arrete reste celle du 31/12/2025 : la difference d''estimation est inchangee a 850 000,00 et aucune ecriture nouvelle n''est produite. Le lot reste propose et perime, a trancher par le chef de mission.',N'1',N'0',N'2026-09-06 01:06:39.091',N'installation (servie_par)');
    SET IDENTITY_INSERT dbo.[demande_reevaluation] OFF;
    PRINT 'demande_reevaluation : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'demande_reevaluation : deja chargee, rien a faire.';
GO
