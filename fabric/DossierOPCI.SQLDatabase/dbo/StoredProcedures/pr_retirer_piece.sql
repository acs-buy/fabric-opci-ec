
-- 1.2 : la reprise. Droit en tete (50980), puis motif (50277), rattachement (50278), verrou (50303), donnee fondee
-- (50279) ; le rattachement designe, ou, sans lui, le dernier de la piece (appels directs d'aujourd'hui).
CREATE   PROCEDURE dbo.pr_retirer_piece
    @entite          VARCHAR (20),
    @piece_id        INT = NULL,
    @motif           NVARCHAR (800),
    @par             NVARCHAR (400),
    @rattachement_id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @nom NVARCHAR (400), @question VARCHAR (20), @arrete VARCHAR (20), @ratt INT, @piece INT, @refus NVARCHAR (400);
    -- le rattachement en cause
    IF @rattachement_id IS NOT NULL
        SELECT @ratt = pr.id, @piece = pr.piece_id, @arrete = pr.arrete FROM dbo.piece_rattachement pr
        WHERE pr.id = @rattachement_id AND pr.entite = @entite AND (@piece_id IS NULL OR pr.piece_id = @piece_id);
    ELSE IF @piece_id IS NOT NULL
        SELECT TOP (1) @ratt = pr.id, @piece = pr.piece_id, @arrete = pr.arrete FROM dbo.piece_rattachement pr
        WHERE pr.piece_id = @piece_id AND pr.entite = @entite ORDER BY pr.id DESC;
    -- 1. le droit, avant tout autre refus
    IF dbo.fn_membre_equipe(@entite, @arrete, @par, CAST(SYSUTCDATETIME() AS DATE)) = 0
        THROW 50980, N'Retrait refusé : votre adresse de connexion n''est rattachée à aucun membre de l''équipe de ce dossier.', 1;
    SET @motif = NULLIF(LTRIM(RTRIM(@motif)), N'');
    IF @motif IS NULL
        THROW 50277, N'Le motif du retrait est obligatoire : il reste dans la trace du dossier.', 1;
    IF @ratt IS NULL
        THROW 50278, N'Cette pièce n''est pas rattachée à ce dossier.', 1;
    SET @refus = dbo.fn_refus_retrait_piece(@entite, @ratt);
    IF @refus IS NOT NULL
    BEGIN
        SET @refus = REPLACE(@refus, N'%', N'%%');
        IF @refus LIKE N'Le dossier de l''arrêté%' THROW 50303, @refus, 1;
        THROW 50279, @refus, 1;
    END;
    SELECT @nom = p.nom_fichier, @question = q.reference
    FROM dbo.piece_rattachement pr JOIN dbo.piece p ON p.id = pr.piece_id LEFT JOIN dbo.ref_question q ON q.id = pr.question_id
    WHERE pr.id = @ratt;

    DECLARE @tc INT = @@TRANCOUNT;
    BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO dbo.journal_piece (piece_id, nom_fichier, entite, question, arrete, action, motif, fait_par)
    VALUES (@piece, @nom, @entite, @question, @arrete, 'RETRAIT', @motif, @par);
    DELETE dbo.piece_rattachement WHERE id = @ratt;
    IF NOT EXISTS (SELECT 1 FROM dbo.piece_rattachement WHERE piece_id = @piece)
       AND NOT EXISTS (SELECT 1 FROM dbo.releve_coffre_refus WHERE piece_en_face = @piece)
        DELETE dbo.piece WHERE id = @piece;
    COMMIT;
    END TRY
    BEGIN CATCH
        IF @tc = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    -- 1.2, point 6 : le message de reussite, seul a nommer le fichier
    DECLARE @autres INT, @autres_arretes INT, @autre_arrete VARCHAR (20);
    SELECT @autres = COUNT(*), @autres_arretes = COUNT(arrete), @autre_arrete = MAX(arrete) FROM dbo.piece_rattachement WHERE piece_id = @piece;
    SELECT @piece AS piece_id,
           N'Pièce « ' + @nom + N' » retirée du dossier ' + CASE WHEN LEFT(@entite, 1) LIKE N'[AEIOUYaeiouyÉéÈèÊêÀàÂâÎîÔôÛû]' THEN N'd''' ELSE N'de ' END + @entite
         + CASE WHEN @question IS NOT NULL THEN N' (question ' + @question + N')' ELSE N'' END
         + CASE WHEN @arrete IS NOT NULL THEN N', arrêté du ' + dbo.fn_date_ecran(@arrete) ELSE N'' END
         + N'. Le fichier reste dans SharePoint ; le retrait est tracé.'
         + CASE WHEN @autres = 1 AND @autres_arretes = 1 THEN N' Elle reste rattachée à l''arrêté du ' + dbo.fn_date_ecran(@autre_arrete) + N'.'
                WHEN @autres = 1 THEN N' Elle garde 1 autre rattachement.'
                WHEN @autres > 1 AND @autres_arretes = @autres THEN N' Elle reste rattachée à ' + CAST(@autres AS NVARCHAR (10)) + N' autres arrêtés.'
                WHEN @autres > 1 THEN N' Elle garde ' + CAST(@autres AS NVARCHAR (10)) + N' autres rattachements.'
                ELSE N'' END AS message;
END;

GO

