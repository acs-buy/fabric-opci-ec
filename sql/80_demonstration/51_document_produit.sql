-- document_produit : 1 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[document_produit])
BEGIN
    INSERT INTO dbo.[document_produit] ([id], [entite], [arrete], [livrable], [version], [chemin_coffre], [empreinte_sha256], [produit_par], [produit_le], [perime_le], [perime_motif]) VALUES
        (N'1',N'OMEGA-OPCI',N'2025-12-31',N'ATTESTATION',N'1',N'/Coffre/OMEGA-OPCI/2025-12-31/attestation.pdf',N'507C36DAD1B46547EADB3AE42D3A0CBA025B1FA5E7D20EA50A843DA7399ABDD8',N'installation',N'2026-09-06 01:11:29.406',N'2026-09-13 11:44:25.399',N'Arrêté rouvert le 13/09/2026 : Reouverture demandee par le candidat le 13/09/2026 : l arrete porte le jeu de demonstration du memoire et doit montrer un dossier en cours de revision. Le document a été produit sur des comptes antérieurs à la réouverture.');
    PRINT 'document_produit : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'document_produit : deja chargee, rien a faire.';
GO
