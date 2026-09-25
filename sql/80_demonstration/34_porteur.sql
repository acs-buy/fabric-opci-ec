-- porteur : 6 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[porteur])
BEGIN
    INSERT INTO dbo.[porteur] ([entite], [code], [denomination], [source]) VALUES
        (N'OMEGA-OPCI',N'PORT-01',N'Institutionnel A',N'SIMULE : registre des porteurs du cas construit'),
        (N'OMEGA-OPCI',N'PORT-02',N'Institutionnel B',N'SIMULE : registre des porteurs du cas construit'),
        (N'OMEGA-OPCI',N'PORT-03',N'Famille C',N'SIMULE : registre des porteurs du cas construit'),
        (N'OPCI-1',N'PORT-11',N'Institutionnel D',N'SIMULE : registre des porteurs du cas construit'),
        (N'OPCI-1',N'PORT-12',N'Famille E',N'SIMULE : registre des porteurs du cas construit'),
        (N'OMEGA-OPCI',N'PORT-04',N'Personne physique D',N'SIMULE : registre des porteurs du cas construit');
    PRINT 'porteur : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'porteur : deja chargee, rien a faire.';
GO
