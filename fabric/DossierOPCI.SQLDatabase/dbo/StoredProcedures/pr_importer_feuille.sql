
-- --- 2. l'import d'une feuille remplie : conclusion, forme, fichier -----------------------------------
CREATE   PROCEDURE dbo.pr_importer_feuille
    @cote         VARCHAR (30),
    @conclusion   NVARCHAR (MAX)  = NULL,
    @forme        VARCHAR (20)    = NULL,        -- SANS_OBSERVATION, AVEC_OBSERVATION, REFUS_ATTESTER : conclut la feuille
    @nom_fichier  NVARCHAR (400)  = NULL,
    @empreinte    CHAR (64)       = NULL,
    @par          NVARCHAR (400),
    @objectif     NVARCHAR (MAX)  = NULL         -- NULL laisse l'objectif en place
AS
BEGIN
    SET NOCOUNT ON;
    -- 327 debut (24/10/2026) : un champ vide se refuse en francais avant toute ecriture, au texte du champ dans le
    -- plan de l'etude des fonctions (decision A du candidat). Genere par 61_DEPLOIEMENT/generer_327_refus_champs_vides.py.
    -- le vide : les 29 caracteres de str.isspace(), compares au point de code
    DECLARE @r327_blancs NVARCHAR (29) = NCHAR(9) + NCHAR(10) + NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(28) + NCHAR(29) + NCHAR(30) + NCHAR(31) + NCHAR(32)
        + NCHAR(133) + NCHAR(160) + NCHAR(5760) + NCHAR(8192) + NCHAR(8193) + NCHAR(8194) + NCHAR(8195) + NCHAR(8196) + NCHAR(8197) + NCHAR(8198)
        + NCHAR(8199) + NCHAR(8200) + NCHAR(8201) + NCHAR(8202) + NCHAR(8232) + NCHAR(8233) + NCHAR(8239) + NCHAR(8287) + NCHAR(12288);
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @cote COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51212, N'Conclusion refusée : choisissez dans la grille « Questions du cycle » une question dont la feuille de travail est ouverte.', 1;
    -- 327 fin
    DECLARE @entite VARCHAR (20), @arrete VARCHAR (20), @conclue DATETIME2 (3);
    SELECT @entite = entite, @arrete = arrete, @conclue = conclue_le FROM dbo.feuille_travail WHERE cote = @cote;
    IF @entite IS NULL
        THROW 50371, N'La feuille désignée n''existe pas.', 1;
    IF dbo.fn_dossier_verrouille(@entite, @arrete) = 1
        THROW 50303, N'Le dossier de cet arrêté est visé et verrouillé.', 1;
    IF @conclue IS NOT NULL AND EXISTS (SELECT 1 FROM dbo.visa WHERE nature = 'CONCLUSION' AND objet_ref = @cote AND decision = 'VISE')
        THROW 50372, N'Cette feuille est conclue et visée ; elle ne se modifie plus.', 1;
    -- UN TEXTE TROP LONG EST REFUSE, JAMAIS TRONQUE.
    IF LEN(@objectif) > 1000
        THROW 50521, N'Feuille refusée : l''objectif dépasse 1000 caractères.', 1;
    IF LEN(@conclusion) > 400
        THROW 50522, N'Feuille refusée : la conclusion dépasse 400 caractères.', 1;
    IF @forme IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.ref_forme_conclusion WHERE code = @forme)
        THROW 50373, N'La forme de conclusion est SANS_OBSERVATION, AVEC_OBSERVATION ou REFUS_ATTESTER.', 1;
    -- texte et forme entrent ensemble ou pas du tout : une porte de la conclusion (pieces du cycle, derogation)
    -- qui refuse la forme ne laisse pas un texte orphelin
    BEGIN TRY
    BEGIN TRANSACTION;
    UPDATE dbo.feuille_travail
       SET conclusion = COALESCE(@conclusion, conclusion),
           objectif = COALESCE(@objectif, objectif),
           nom_fichier = COALESCE(@nom_fichier, nom_fichier),
           empreinte_sha256 = COALESCE(@empreinte, empreinte_sha256)
     WHERE cote = @cote;
    IF @forme IS NOT NULL
        EXEC dbo.pr_conclure_feuille @cote, @forme, @par;
    COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
    SELECT @cote AS cote,
           N'Feuille ' + @cote + N' reprise' + CASE WHEN @forme IS NOT NULL THEN N' et conclue (' + @forme + N')' ELSE N'' END + N'.' AS message;
END;

GO

