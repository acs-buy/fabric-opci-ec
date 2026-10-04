
CREATE   PROCEDURE dbo.pr_rattacher_piece_attendue
    @entite            VARCHAR (20),
    @piece_id          INT,
    @piece_attendue_id INT,
    @arrete            VARCHAR (20)   = NULL,
    @par               NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @m NVARCHAR (400), @periodicite VARCHAR (12), @vigueur DATE, @retenu VARCHAR (20), @date DATE;
    IF NOT EXISTS (SELECT 1 FROM dbo.piece WHERE id = @piece_id AND entite = @entite)
    BEGIN
        SET @m = N'Rattachement refusé : la pièce n° ' + ISNULL(CAST(@piece_id AS NVARCHAR (12)), N'vide') + N' n''est pas inscrite au dossier de l''entité ' + ISNULL(@entite, N'vide') + N'.';
        THROW 50524, @m, 1;
    END;
    SELECT @periodicite = periodicite, @vigueur = en_vigueur_depuis FROM dbo.ref_piece_attendue WHERE id = @piece_attendue_id;
    IF @periodicite IS NULL
        THROW 50525, N'Rattachement refusé : la pièce attendue désignée n''existe pas, ou n''est pas en vigueur à cet arrêté.', 1;
    IF @periodicite = 'PERMANENT'
        SELECT TOP (1) @retenu = arrete, @date = date_arrete FROM dbo.ref_arrete WHERE entite = @entite
        ORDER BY CASE WHEN porte_balance = 1 THEN 0 ELSE 1 END, date_arrete, arrete;
    ELSE
    BEGIN
        IF NULLIF(LTRIM(RTRIM(@arrete)), '') IS NULL
            THROW 50526, N'Rattachement refusé : cette pièce attendue est exigée à chaque arrêté ; désigner l''arrêté.', 1;
        SELECT @retenu = arrete, @date = date_arrete FROM dbo.ref_arrete WHERE entite = @entite AND arrete = @arrete;
        IF @retenu IS NULL
            THROW 50526, N'Rattachement refusé : cette pièce attendue est exigée à chaque arrêté ; désigner un arrêté au référentiel de l''entité.', 1;
    END;
    IF @retenu IS NULL OR (@vigueur IS NOT NULL AND @vigueur > @date)
        THROW 50525, N'Rattachement refusé : la pièce attendue désignée n''existe pas, ou n''est pas en vigueur à cet arrêté.', 1;
    IF EXISTS (SELECT 1 FROM dbo.piece_rattachement WHERE piece_id = @piece_id AND piece_attendue_id = @piece_attendue_id
               AND entite_couverte = @entite AND arrete_couvert = @retenu)
        THROW 50527, N'Rattachement refusé : cette pièce couvre déjà cette pièce attendue pour cet arrêté.', 1;
    INSERT INTO dbo.piece_rattachement (piece_id, entite, arrete, question_id, code_actif, rattache_par, rattache_le,
                                        piece_attendue_id, entite_couverte, arrete_couvert)
    VALUES (@piece_id, @entite, @retenu, NULL, NULL, @par, SYSUTCDATETIME(), @piece_attendue_id, @entite, @retenu);
    SELECT SCOPE_IDENTITY() AS rattachement_id, @retenu AS arrete_couvert,
           N'Pièce n° ' + CAST(@piece_id AS NVARCHAR (12)) + N' rattachée à la pièce attendue n° ' + CAST(@piece_attendue_id AS NVARCHAR (12))
         + N', pour l''arrêté ' + @retenu + N'.' AS message;
END;

GO

