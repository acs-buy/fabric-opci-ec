-- ref_role : 4 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_role])
BEGIN
    INSERT INTO dbo.[ref_role] ([code], [libelle], [vise], [ordre], [modifie_par], [modifie_le]) VALUES
        (N'ASSOCIE',N'Associe signataire : signe l''attestation et la publication',N'1',N'2',NULL,NULL),
        (N'CHEF_MISSION',N'Chef de mission : vise les lots, les conclusions, les derogations et les ecarts',N'1',N'1',NULL,NULL),
        (N'PREPARATEUR',N'Preparateur : prepare les feuilles et propose les lots',N'0',N'4',NULL,NULL),
        (N'REVISEUR',N'Reviseur : revoit les feuilles de travail',N'0',N'3',NULL,NULL);
    PRINT 'ref_role : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_role : deja chargee, rien a faire.';
GO
