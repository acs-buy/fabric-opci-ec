-- ref_forme_conclusion : 3 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_forme_conclusion])
BEGIN
    INSERT INTO dbo.[ref_forme_conclusion] ([code], [libelle], [reference_id], [favorable], [ordre], [modifie_par], [modifie_le]) VALUES
        (N'AVEC_OBSERVATION',N'Conclusion favorable assortie d''une ou de plusieurs observations',N'7',N'1',N'2',NULL,NULL),
        (N'REFUS_ATTESTER',N'Refus d''attester',N'8',N'0',N'3',NULL,NULL),
        (N'SANS_OBSERVATION',N'Conclusion favorable sans observation',N'6',N'1',N'1',NULL,NULL);
    PRINT 'ref_forme_conclusion : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_forme_conclusion : deja chargee, rien a faire.';
GO
