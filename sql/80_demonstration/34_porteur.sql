-- porteur : 6 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[porteur])
BEGIN
    SET IDENTITY_INSERT dbo.[porteur] ON;
    INSERT INTO dbo.[porteur] ([id], [entite], [code], [denomination], [source]) VALUES
        (N'1',N'OMEGA-OPCI',N'PORT-01',N'Institutionnel A',N'SIMULE : registre des porteurs du cas construit'),
        (N'2',N'OMEGA-OPCI',N'PORT-02',N'Institutionnel B',N'SIMULE : registre des porteurs du cas construit'),
        (N'3',N'OMEGA-OPCI',N'PORT-03',N'Famille C',N'SIMULE : registre des porteurs du cas construit'),
        (N'4',N'OPCI-1',N'PORT-11',N'Institutionnel D',N'SIMULE : registre des porteurs du cas construit'),
        (N'5',N'OPCI-1',N'PORT-12',N'Famille E',N'SIMULE : registre des porteurs du cas construit'),
        (N'6',N'OMEGA-OPCI',N'PORT-04',N'Personne physique D',N'SIMULE : registre des porteurs du cas construit');
    SET IDENTITY_INSERT dbo.[porteur] OFF;
    PRINT 'porteur : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'porteur : deja chargee, rien a faire.';
GO
