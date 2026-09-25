-- ref_nature_piece : 10 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_nature_piece])
BEGIN
    INSERT INTO dbo.[ref_nature_piece] ([code], [libelle], [famille], [conservation], [reference_id], [ordre], [source], [modifie_par], [modifie_le]) VALUES
        (N'ACCEPTATION',N'Piece de l''acceptation de la mission',N'MISSION',N'PERMANENTE',N'27',N'2',N'NP 2300 paragraphe 7 et NPMQ paragraphes 18 a 20. Nature retenue par la pratique.',NULL,NULL),
        (N'ACTE_ACQUISITION',N'Acte d''acquisition ou de cession',N'JURIDIQUE',N'PERMANENTE',NULL,N'6',N'Pratique du dossier : la piece qui fonde le prix de revient, article 211-1.',NULL,NULL),
        (N'BAIL',N'Bail ou avenant',N'JURIDIQUE',N'DUREE_MISSION',NULL,N'7',N'Pratique du dossier : la piece qui fonde le loyer, article 211-10.',NULL,NULL),
        (N'BALANCE',N'Balance generale de l''entite',N'COMPTABLE',N'EXERCICE',N'2',N'3',N'Pratique du dossier : aucun texte ne prescrit un format de balance.',NULL,NULL),
        (N'CONTRAT_EMPRUNT',N'Contrat d''emprunt ou convention de compte courant',N'FINANCIER',N'PERMANENTE',NULL,N'9',N'Pratique du dossier : la piece qui fonde le taux et l''affectation, articles 322-5 et 322-9.',NULL,NULL),
        (N'GRAND_LIVRE',N'Grand livre ou fichier des ecritures',N'COMPTABLE',N'EXERCICE',N'2',N'4',N'Article A. 47 A-1 du livre des procedures fiscales pour le fichier des ecritures. Texte non verse au dossier.',NULL,NULL),
        (N'LETTRE_MISSION',N'Lettre de mission',N'MISSION',N'PERMANENTE',N'28',N'1',N'NP 2300 paragraphe 8, intitule releve au sommaire. Nature retenue par la pratique du dossier.',NULL,NULL),
        (N'PV_ASSEMBLEE',N'Proces-verbal d''assemblee ou de conseil',N'JURIDIQUE',N'PERMANENTE',NULL,N'10',N'Pratique du dossier : la piece qui fonde l''affectation du resultat et la distribution.',NULL,NULL),
        (N'RAPPORT_EVALUATION',N'Rapport d''un evaluateur immobilier',N'IMMOBILIER',N'EXERCICE',NULL,N'5',N'Article L. 214-55 du code monetaire et financier, dont le texte n''est pas au dossier. Le reglement ANC 2021-09 ne prescrit aucun rapport, article 211-6.',NULL,NULL),
        (N'RELEVE_BANCAIRE',N'Releve bancaire',N'FINANCIER',N'EXERCICE',NULL,N'8',N'Pratique du dossier.',NULL,NULL);
    PRINT 'ref_nature_piece : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_nature_piece : deja chargee, rien a faire.';
GO
