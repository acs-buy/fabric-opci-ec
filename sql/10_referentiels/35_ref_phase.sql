-- ref_phase : 7 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_phase])
BEGIN
    INSERT INTO dbo.[ref_phase] ([code], [libelle], [niveau], [ordre], [modifie_par], [modifie_le], [ecartee_le], [ecartee_par], [motif_ecart]) VALUES
        (N'ACCEPT',N'Acceptation',N'MISSION',N'1',NULL,NULL,NULL,NULL,NULL),
        (N'COHERENCE',N'Cohérence et vraisemblance',N'ARRETE',N'4',NULL,NULL,NULL,NULL,NULL),
        (N'COMPTES',N'Comptes annuels',N'ANNUEL',N'5',NULL,NULL,NULL,NULL,NULL),
        (N'MAINTIEN',N'Maintien de mission',N'ANNUEL',N'7',NULL,NULL,NULL,NULL,NULL),
        (N'PERMANENT',N'Dossier permanent',N'MISSION',N'2',NULL,NULL,NULL,NULL,NULL),
        (N'PLANIF',N'Planification',N'ARRETE',N'3',NULL,NULL,NULL,NULL,NULL),
        (N'SYNTHESE',N'Note de synthèse',N'ANNUEL',N'6',NULL,NULL,NULL,NULL,NULL);
    PRINT 'ref_phase : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_phase : deja chargee, rien a faire.';
GO
