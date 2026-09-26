-- publication_vl : 1 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[publication_vl])
BEGIN
    SET IDENTITY_INSERT dbo.[publication_vl] ON;
    INSERT INTO dbo.[publication_vl] ([id], [entite], [arrete], [valeur_liquidative], [nombre_parts], [version_regles], [publie_par], [publie_le]) VALUES
        (N'1',N'OMEGA-OPCI',N'2025-12-31',N'114.84',N'1407990.0000',N'v1',N'installation',N'2026-09-06 01:06:36.353');
    SET IDENTITY_INSERT dbo.[publication_vl] OFF;
    PRINT 'publication_vl : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'publication_vl : deja chargee, rien a faire.';
GO
