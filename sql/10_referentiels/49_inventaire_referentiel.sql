-- inventaire_referentiel : 23 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[inventaire_referentiel])
BEGIN
    INSERT INTO dbo.[inventaire_referentiel] ([table_nom], [lignes], [lignes_modifiees], [derniere_modification], [releve_le]) VALUES
        (N'modele_ecriture',N'40',N'0',NULL,N'2026-09-06 01:07:05.145'),
        (N'modele_feuille',N'24',N'0',NULL,N'2026-09-06 01:07:05.145'),
        (N'ref_article',N'105',N'0',NULL,N'2026-09-06 01:07:05.145'),
        (N'ref_compte',N'200',N'0',NULL,N'2026-09-06 01:07:05.145'),
        (N'ref_compte_entite',N'195',N'0',NULL,N'2026-09-06 01:07:05.145'),
        (N'ref_contrepartie_estimation',N'7',N'0',NULL,N'2026-09-06 01:07:05.145'),
        (N'ref_correspondance_plan',N'13',N'0',NULL,N'2026-09-06 01:07:05.145'),
        (N'ref_cycle',N'11',N'0',NULL,N'2026-09-06 01:07:05.145'),
        (N'ref_entite',N'16',N'0',NULL,N'2026-09-06 01:07:05.145'),
        (N'ref_forme_conclusion',N'3',N'0',NULL,N'2026-09-06 01:07:05.145'),
        (N'ref_nature_actif',N'17',N'0',NULL,N'2026-09-06 01:07:05.145'),
        (N'ref_nature_arrete',N'3',N'0',NULL,N'2026-09-06 01:07:05.145'),
        (N'ref_nature_piece',N'10',N'0',NULL,N'2026-09-06 01:07:05.145'),
        (N'ref_norme',N'23',N'0',NULL,N'2026-09-06 01:07:05.145'),
        (N'ref_phase',N'7',N'0',NULL,N'2026-09-06 01:07:05.145'),
        (N'ref_piece_attendue',N'77',N'0',NULL,N'2026-09-06 01:07:05.145'),
        (N'ref_question',N'620',N'0',NULL,N'2026-09-06 01:07:05.145'),
        (N'ref_question_article',N'511',N'0',NULL,N'2026-09-06 01:07:05.145'),
        (N'ref_question_modele',N'64',N'0',NULL,N'2026-09-06 01:07:05.145'),
        (N'ref_question_reference',N'113',N'0',NULL,N'2026-09-06 01:07:05.145'),
        (N'ref_reference',N'178',N'0',NULL,N'2026-09-06 01:07:05.145'),
        (N'ref_role',N'4',N'0',NULL,N'2026-09-06 01:07:05.145'),
        (N'role_nature_visa',N'8',N'0',NULL,N'2026-09-06 01:07:05.145');
    PRINT 'inventaire_referentiel : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'inventaire_referentiel : deja chargee, rien a faire.';
GO
