-- ref_aide : 2 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_aide])
BEGIN
    INSERT INTO dbo.[ref_aide] ([code], [libelle_lien], [titre_page], [url], [portee], [parcours], [feuille], [ordre], [modifie_par], [modifie_le]) VALUES
        (N'COMMENT_CA_MARCHE',N'Comment ça marche',N'Ce que voit le réviseur',N'https://github.com/acs-buy/fabric-opci-ec/blob/main/docs/comprendre/02-ce-que-voit-le-reviseur.md',N'TOUS',NULL,NULL,N'1',NULL,NULL),
        (N'ORDRE_DES_ECRANS',N'L''ordre des écrans',N'Les cinq temps du dossier',N'https://github.com/acs-buy/fabric-opci-ec/blob/main/docs/comprendre/02-ce-que-voit-le-reviseur.md#les-cinq-temps-du-dossier',N'TOUS',NULL,NULL,N'2',NULL,NULL);
    PRINT 'ref_aide : ' + CAST((SELECT COUNT(*) FROM dbo.[ref_aide]) AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_aide : deja chargee, rien a faire.';
GO
