-- derogation : 1 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[derogation])
BEGIN
    INSERT INTO dbo.[derogation] ([entite], [arrete], [cote], [motif], [accordee_par], [accordee_le], [levee_par], [levee_le], [message_ecran], [message_ecran_le], [message_ecran_pour]) VALUES
        (N'OMEGA-OPCI',N'2025-12-31',N'DEM-VALO-OMEGA-OPCI-20251231',N'SIMULE : rapport d''evaluateur non parvenu a la date d''arrete sur IMM-201. Valeur retenue par modele, sous reserve de reception du rapport.',N'installation',N'2026-09-06 01:06:36.041',NULL,NULL,NULL,NULL,NULL);
    PRINT 'derogation : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'derogation : deja chargee, rien a faire.';
GO
