-- ref_question_compte : 40 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_question_compte])
BEGIN
    INSERT INTO dbo.[ref_question_compte] ([question_id], [racine], [source], [modifie_par], [modifie_le], [ecartee_le], [ecartee_par], [motif_ecart]) VALUES
        (N'5',N'104',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'5',N'405',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'6',N'104',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'6',N'405',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'82',N'104',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'82',N'405',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'101',N'266',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'101',N'661',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'102',N'266',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'102',N'661',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'167',N'105',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'167',N'271',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'168',N'105',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'168',N'271',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'169',N'105',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'169',N'271',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'175',N'105',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'175',N'276',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'176',N'105',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'176',N'276',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'189',N'467',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'189',N'511',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'196',N'104',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'196',N'405',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'197',N'104',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'197',N'761',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'198',N'104',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'198',N'405',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'199',N'104',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'199',N'761',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'201',N'103',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'201',N'467',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'219',N'405',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'219',N'761',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'220',N'104',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'220',N'761',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'223',N'266',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'223',N'661',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'252',N'129',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL),
        (N'252',N'511',N'modele_ecriture, derive le 16/09/2026',NULL,NULL,NULL,NULL,NULL);
    PRINT 'ref_question_compte : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_question_compte : deja chargee, rien a faire.';
GO
