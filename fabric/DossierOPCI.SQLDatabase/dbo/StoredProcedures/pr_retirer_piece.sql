
CREATE   PROCEDURE dbo.pr_retirer_piece
    @entite    VARCHAR (20),
    @piece_id  INT,
    @motif     NVARCHAR (800),
    @par       NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @motif = NULLIF(LTRIM(RTRIM(@motif)), N'');
    IF @motif IS NULL
        THROW 50277, N'Le motif du retrait est obligatoire : il reste dans la trace du dossier.', 1;
    DECLARE @nom NVARCHAR (400), @question VARCHAR (20), @arrete VARCHAR (20), @ratt INT;
    SELECT TOP (1) @ratt = pr.id, @nom = p.nom_fichier, @arrete = pr.arrete, @question = q.reference
      FROM dbo.piece_rattachement pr
      JOIN dbo.piece p ON p.id = pr.piece_id
      LEFT JOIN dbo.ref_question q ON q.id = pr.question_id
     WHERE pr.piece_id = @piece_id AND pr.entite = @entite
     ORDER BY pr.id DESC;
    IF @ratt IS NULL
        THROW 50278, N'Cette pièce n''est pas rattachée à ce dossier.', 1;
    IF @arrete IS NOT NULL AND dbo.fn_dossier_verrouille(@entite, @arrete) = 1
        THROW 50303, N'Le dossier de cet arrêté est visé et verrouillé : il s''exporte, il ne se modifie plus.', 1;
    IF EXISTS (SELECT 1 FROM dbo.lot_ecritures WHERE piece_id = @piece_id)
       OR EXISTS (SELECT 1 FROM dbo.expertise WHERE piece_id = @piece_id)
       OR EXISTS (SELECT 1 FROM dbo.mouvement_actif WHERE piece_id = @piece_id)
       OR EXISTS (SELECT 1 FROM dbo.rapport_annuel WHERE piece_synthese_id = @piece_id OR piece_certification_id = @piece_id)
       OR EXISTS (SELECT 1 FROM dbo.eligibilite_participation WHERE accord_ecrit_piece_id = @piece_id)
       OR EXISTS (SELECT 1 FROM dbo.feuille_piece WHERE piece_id = @piece_id)
    BEGIN
        DECLARE @m NVARCHAR (600) = N'La pièce « ' + @nom + N' » fonde une donnée de mission (écritures, expertise, rapport, mouvement, accord ou feuille) : elle ne se retire pas du dossier.';
        INSERT INTO dbo.journal_refus (procedure_nom, entite, cote, message, geste, refuse_pour, refuse_le)
        VALUES ('pr_retirer_piece', @entite, NULL, @m, N'Retirer d''abord ce qui s''appuie sur la pièce.', @par, SYSUTCDATETIME());
        THROW 50279, @m, 1;
    END;

    BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO dbo.journal_piece (piece_id, nom_fichier, entite, question, arrete, action, motif, fait_par)
    VALUES (@piece_id, @nom, @entite, @question, @arrete, 'RETRAIT', @motif, @par);
    DELETE dbo.piece_rattachement WHERE id = @ratt;
    IF NOT EXISTS (SELECT 1 FROM dbo.piece_rattachement WHERE piece_id = @piece_id)
       AND NOT EXISTS (SELECT 1 FROM dbo.releve_coffre_refus WHERE piece_en_face = @piece_id)
        DELETE dbo.piece WHERE id = @piece_id;
    COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @piece_id AS piece_id,
           N'Pièce « ' + @nom + N' » retirée du dossier de ' + @entite
         + CASE WHEN @question IS NOT NULL THEN N' (question ' + @question + N')' ELSE N'' END
         + N'. Le fichier reste au coffre ; le retrait est tracé.' AS message;
END;

GO

