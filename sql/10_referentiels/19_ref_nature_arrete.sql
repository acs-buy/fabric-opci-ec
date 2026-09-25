-- ref_nature_arrete : 3 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_nature_arrete])
BEGIN
    INSERT INTO dbo.[ref_nature_arrete] ([code], [libelle], [note], [ordre], [modifie_par], [modifie_le]) VALUES
        (N'ANNUEL',N'Arrêté annuel',N'Clôture de l''exercice. Porte les comptes annuels, l''affectation du résultat et l''attestation.',N'1',NULL,NULL),
        (N'INTERMEDIAIRE',N'Arrêté intermédiaire',N'Arrêté de valeur liquidative hors clôture et hors semestre.',N'3',NULL,NULL),
        (N'SEMESTRIEL',N'Arrêté semestriel',N'Porte le document d''information périodique. L''affectation du résultat n''y a pas lieu : le cycle AFFECT a pour applicabilité ARRETE_CLOTURE.',N'2',NULL,NULL);
    PRINT 'ref_nature_arrete : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_nature_arrete : deja chargee, rien a faire.';
GO
