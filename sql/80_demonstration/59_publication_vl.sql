-- publication_vl : 2 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[publication_vl])
BEGIN
    SET IDENTITY_INSERT dbo.[publication_vl] ON;
    INSERT INTO dbo.[publication_vl] ([id], [entite], [arrete], [valeur_liquidative], [nombre_parts], [version_regles], [publie_par], [publie_le], [perimee_le]) VALUES
        (N'1',N'OMEGA-OPCI',N'2025-12-31',N'114.84',N'1407990.0000',N'v1',N'installation',N'2026-09-06 01:06:36.353',N'2026-10-19 13:50:15.028'),
        (N'8',N'OMEGA-OPCI',N'2025-12-31',N'115.38',N'1407990.0000',N'val275-v1',N'installation',N'2026-10-19 13:50:15.092',NULL);
    SET IDENTITY_INSERT dbo.[publication_vl] OFF;
    DECLARE @n INT = (SELECT COUNT(*) FROM dbo.[publication_vl]);
    PRINT 'publication_vl : ' + CAST(@n AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'publication_vl : deja chargee, rien a faire.';
GO
