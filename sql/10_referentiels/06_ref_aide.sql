-- ref_aide : 2 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_aide])
BEGIN
    INSERT INTO dbo.[ref_aide] ([code], [libelle_lien], [titre_page], [url], [portee], [parcours], [feuille], [ordre], [modifie_par], [modifie_le]) VALUES
        (N'COMMENT_CA_MARCHE',N'Comment ça marche',N'Le parcours du réviseur : les 88 écrans en 4 étapes',N'https://claude.ai/code/artifact/e191aa4c-70d1-43a6-8062-0af3b0cb6adb',N'TOUS',NULL,NULL,N'1',NULL,NULL),
        (N'ORDRE_DES_ECRANS',N'L''ordre des écrans',N'Les 69 écrans de travail rangés en 4 étapes de 5 temps',N'https://claude.ai/code/artifact/0ce5885d-befc-46f8-b3ca-2e68d0d90a19',N'TOUS',NULL,NULL,N'2',NULL,NULL);
    PRINT 'ref_aide : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_aide : deja chargee, rien a faire.';
GO
