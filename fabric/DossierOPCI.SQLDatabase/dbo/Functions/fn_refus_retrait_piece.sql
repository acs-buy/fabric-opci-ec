
-- 1.3 : le texte exact que pr_retirer_piece leverait pour 50303, puis pour 50279, sur le rattachement designe ; NULL
-- sinon. Ni le droit ni le motif.
CREATE   FUNCTION dbo.fn_refus_retrait_piece (@entite VARCHAR (20), @rattachement_id INT)
RETURNS NVARCHAR (400)
AS
BEGIN
    DECLARE @piece INT, @arrete VARCHAR (20), @ent VARCHAR (20), @cote VARCHAR (30), @donnee NVARCHAR (60);
    SELECT @piece = piece_id, @arrete = arrete, @ent = entite FROM dbo.piece_rattachement WHERE id = @rattachement_id AND entite = @entite;
    IF @piece IS NULL RETURN NULL;
    IF @arrete IS NOT NULL AND dbo.fn_dossier_verrouille(@ent, @arrete) = 1
        RETURN N'Le dossier de l''arrêté du ' + dbo.fn_date_ecran(@arrete) + N' est visé et verrouillé : la pièce ne s''en retire plus.';
    SET @donnee = CASE WHEN EXISTS (SELECT 1 FROM dbo.lot_ecritures WHERE piece_id = @piece) THEN N'des écritures'
                       WHEN EXISTS (SELECT 1 FROM dbo.expertise WHERE piece_id = @piece) THEN N'une expertise'
                       WHEN EXISTS (SELECT 1 FROM dbo.mouvement_actif WHERE piece_id = @piece) THEN N'un mouvement d''actif'
                       WHEN EXISTS (SELECT 1 FROM dbo.rapport_annuel WHERE piece_synthese_id = @piece OR piece_certification_id = @piece) THEN N'un rapport annuel'
                       WHEN EXISTS (SELECT 1 FROM dbo.eligibilite_participation WHERE accord_ecrit_piece_id = @piece) THEN N'un accord écrit'
                       WHEN EXISTS (SELECT 1 FROM dbo.feuille_piece WHERE piece_id = @piece) THEN N'une feuille de travail' END;
    IF @donnee IS NOT NULL
        RETURN N'La pièce fonde ' + @donnee + N' : elle ne se retire pas du dossier.';
    -- point ouvert 3, A : le rattachement satisfait une piece attendue obligatoire d'une feuille conclue (regle de
    -- tr_feuille_conclusion) ; la 1re cote dans l'ordre des cotes
    SELECT TOP (1) @cote = f.cote
    FROM dbo.piece_rattachement pr
    JOIN dbo.ref_piece_attendue rpa ON rpa.id = pr.piece_attendue_id AND rpa.obligatoire = 1 AND rpa.periodicite IN ('ARRETE', 'PERMANENT')
    JOIN dbo.feuille_travail f ON f.cycle = rpa.cycle AND f.entite = pr.entite AND f.forme_conclusion IS NOT NULL
                              AND (rpa.periodicite = 'PERMANENT' OR pr.arrete = f.arrete)
                              AND (rpa.en_vigueur_depuis IS NULL OR rpa.en_vigueur_depuis <= CONVERT(DATE, f.arrete))
    WHERE pr.id = @rattachement_id
    ORDER BY f.cote;
    IF @cote IS NOT NULL
        RETURN N'La pièce fonde la conclusion de la feuille de travail ' + @cote + N' : elle ne se retire pas du dossier.';
    RETURN NULL;
END;

GO

