-- ref_croisee : 2 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_croisee])
BEGIN
    INSERT INTO dbo.[ref_croisee] ([arrete], [entite], [compte_num], [xref], [etat], [par], [date_etat]) VALUES
        (N'2025-12-31',N'SCI-NORD',N'213',N'IMM-01',N'CONCLUE',N'installation',N'2026-09-06 01:01:55.783'),
        (N'2025-12-31',N'SCI-NORD',N'271',N'IMM-04',N'A_FAIRE',NULL,NULL);
    PRINT 'ref_croisee : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_croisee : deja chargee, rien a faire.';
GO
