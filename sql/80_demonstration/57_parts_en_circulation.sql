-- parts_en_circulation : 5 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[parts_en_circulation])
BEGIN
    INSERT INTO dbo.[parts_en_circulation] ([entite], [arrete], [nombre_parts], [source], [saisi_par], [saisi_le]) VALUES
        (N'OMEGA-OPCI',N'2022-12-31',N'1407990.0000',N'SIMULE : historique 2022-2023',NULL,NULL),
        (N'OMEGA-OPCI',N'2023-12-31',N'1407990.0000',N'SIMULE : historique 2022-2023',NULL,NULL),
        (N'OMEGA-OPCI',N'2024-12-31',N'1407990.0000',N'SIMULE : registre des porteurs du cas construit',NULL,NULL),
        (N'OMEGA-OPCI',N'2025-12-31',N'1407990.0000',N'SIMULE : registre des porteurs du cas construit',NULL,NULL),
        (N'OPCI-1',N'2025-12-31',N'10000.0000',N'SIMULE : registre des porteurs du cas construit',NULL,NULL);
    PRINT 'parts_en_circulation : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'parts_en_circulation : deja chargee, rien a faire.';
GO
