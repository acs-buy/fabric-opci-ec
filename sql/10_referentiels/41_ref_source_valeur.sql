-- ref_source_valeur : 9 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_source_valeur])
BEGIN
    INSERT INTO dbo.[ref_source_valeur] ([source], [libelle], [saisissable], [ordre], [modifie_par], [modifie_le]) VALUES
        (N'ANR_FILIALE',N'Actif net réévalué',N'0',N'7',NULL,NULL),
        (N'CASCADE_212_5',N'Cascade 212-5',N'0',N'9',NULL,NULL),
        (N'EXPERTISE',N'Expertise',N'1',N'1',NULL,NULL),
        (N'MARCHE',N'Marché',N'1',N'3',NULL,NULL),
        (N'MODELE',N'Modèle financier',N'1',N'2',NULL,NULL),
        (N'NOMINAL',N'Nominal',N'1',N'4',NULL,NULL),
        (N'PRIX_CONVENU',N'Prix convenu',N'1',N'6',NULL,NULL),
        (N'PRIX_REVIENT',N'Prix de revient',N'1',N'5',NULL,NULL),
        (N'REVISION',N'Révision',N'0',N'8',NULL,NULL);
    PRINT 'ref_source_valeur : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_source_valeur : deja chargee, rien a faire.';
GO
