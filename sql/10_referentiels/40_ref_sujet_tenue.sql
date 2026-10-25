-- ref_sujet_tenue : 3 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_sujet_tenue])
BEGIN
    INSERT INTO dbo.[ref_sujet_tenue] ([code], [libelle], [ordre], [modifie_par], [modifie_le]) VALUES
        (N'CONCORDANCE_SYSTEMES',N'concordance entre systèmes',N'3',NULL,NULL),
        (N'PISTE_AUDIT_TIERS',N'piste d’audit d’un système tiers',N'1',NULL,NULL),
        (N'REPRISE_A_NOUVEAUX',N'reprise d’à-nouveaux non passés par le cabinet',N'2',NULL,NULL);
    PRINT 'ref_sujet_tenue : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_sujet_tenue : deja chargee, rien a faire.';
GO
