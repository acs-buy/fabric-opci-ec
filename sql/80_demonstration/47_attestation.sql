-- attestation : 1 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[attestation])
BEGIN
    SET IDENTITY_INSERT dbo.[attestation] ON;
    INSERT INTO dbo.[attestation] ([id], [entite], [arrete], [forme], [produit_par], [produit_le], [forme_proposee], [arretee_par], [arretee_le], [motif_limitation]) VALUES
        (N'1',N'OMEGA-OPCI',N'2025-12-31',N'AVEC_OBSERVATION',NULL,NULL,N'AVEC_OBSERVATION',NULL,NULL,NULL);
    SET IDENTITY_INSERT dbo.[attestation] OFF;
    PRINT 'attestation : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'attestation : deja chargee, rien a faire.';
GO
