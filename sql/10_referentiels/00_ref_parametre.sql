-- ref_parametre : 4 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_parametre])
BEGIN
    INSERT INTO dbo.[ref_parametre] ([code], [valeur], [description], [pose_par], [pose_le]) VALUES
        (N'PROGRAMME_ALLEGE_COMPTES_MAX',N'60',N'Programme allege jusqu''a ce nombre de comptes mouvementes. Seuil valide le 29/09/2026.',N'installation',N'2026-09-28 20:51:25.771'),
        (N'PROGRAMME_ALLEGE_FILIALES_MAX',N'0',N'Programme allege jusqu''a ce nombre de filiales ayant une balance. Seuil valide le 29/09/2026.',N'installation',N'2026-09-28 20:51:25.771'),
        (N'PROGRAMME_ETENDU_FILIALES_MIN',N'5',N'Programme etendu a partir de ce nombre de filiales ayant une balance a l''arrete. Seuil valide le 29/09/2026.',N'installation',N'2026-09-28 20:51:25.771'),
        (N'PROGRAMME_ETENDU_SOURCES_MIN',N'2',N'Programme etendu a partir de ce nombre d''imports distincts de la balance de l''entite. Seuil valide le 29/09/2026.',N'installation',N'2026-09-28 20:51:25.771');
    PRINT 'ref_parametre : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_parametre : deja chargee, rien a faire.';
GO
