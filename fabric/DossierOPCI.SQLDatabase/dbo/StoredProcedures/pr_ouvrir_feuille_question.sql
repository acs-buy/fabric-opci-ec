
CREATE   PROCEDURE dbo.pr_ouvrir_feuille_question
    @entite     VARCHAR (20),
    @arrete     VARCHAR (20),
    @reference  VARCHAR (20),
    @par        NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    -- 327 debut (24/10/2026) : un champ vide se refuse en francais avant toute ecriture, au texte du champ dans le
    -- plan de l'etude des fonctions (decision A du candidat). Genere par 61_DEPLOIEMENT/generer_327_refus_champs_vides.py.
    -- le vide : les 29 caracteres de str.isspace(), compares au point de code
    DECLARE @r327_blancs NVARCHAR (29) = NCHAR(9) + NCHAR(10) + NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(28) + NCHAR(29) + NCHAR(30) + NCHAR(31) + NCHAR(32)
        + NCHAR(133) + NCHAR(160) + NCHAR(5760) + NCHAR(8192) + NCHAR(8193) + NCHAR(8194) + NCHAR(8195) + NCHAR(8196) + NCHAR(8197) + NCHAR(8198)
        + NCHAR(8199) + NCHAR(8200) + NCHAR(8201) + NCHAR(8202) + NCHAR(8232) + NCHAR(8233) + NCHAR(8239) + NCHAR(8287) + NCHAR(12288);
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @entite COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51201, N'Choisissez le véhicule dans le sélecteur Véhicule.', 1;
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @arrete COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51202, N'Choisissez l''arrêté dans le sélecteur Arrêté.', 1;
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @reference COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51203, N'Choisissez la question dans la grille « Questions du cycle ».', 1;
    -- 327 fin
    DECLARE @qid INT, @cycle VARCHAR (10);
    SELECT @qid = id, @cycle = cycle FROM dbo.ref_question WHERE reference = @reference;
    IF @qid IS NULL OR @cycle IS NULL
        THROW 50361, N'La question désignée n''est pas une question de cycle du référentiel.', 1;
    IF dbo.fn_dossier_verrouille(@entite, @arrete) = 1
        THROW 50303, N'Le dossier de cet arrêté est visé et verrouillé.', 1;
    DECLARE @cote VARCHAR (30) = (SELECT TOP 1 cote FROM dbo.feuille_travail
                                  WHERE entite = @entite AND arrete = @arrete AND question_id = @qid ORDER BY prepare_le DESC);
    IF @cote IS NOT NULL
    BEGIN
        SELECT @cote AS cote, N'La feuille ' + @cote + N' est déjà ouverte pour la question ' + @reference + N'.' AS message;
        RETURN;
    END;
    DECLARE @modele VARCHAR (20) = ISNULL((SELECT TOP 1 modele_code FROM dbo.ref_question_modele WHERE question_id = @qid ORDER BY modele_code), 'STD');
    -- LA COTE PORTE LE PROGRAMME, depuis le 29/09/2026 : FT-<reference>-P<programme>. Un programme est
    -- unique par entite et arrete, donc la cote l'est sur toute la base. L'ancienne forme,
    -- FT-<reference>-<arrete>, ne portait pas l'entite : deux vehicules ne pouvaient pas avoir la
    -- feuille d'une meme question au meme arrete. Les feuilles deja ouvertes gardent leur cote.
    DECLARE @programme INT = (SELECT id FROM dbo.programme_travail WHERE entite = @entite AND arrete = @arrete);
    IF @programme IS NULL
        THROW 50362, N'Aucun programme n''est choisi pour cet arrêté : la feuille d''une question s''ouvre depuis le programme.', 1;
    SET @cote = 'FT-' + @reference + '-P' + CAST(@programme AS VARCHAR (10));
    IF LEN(@cote) > 30
        THROW 50363, N'La cote de la feuille dépasserait 30 caractères : la référence de la question est trop longue.', 1;
    EXEC dbo.pr_ouvrir_feuille @cote, @modele, @entite, @arrete, @cycle, NULL, @par;
    UPDATE dbo.feuille_travail SET question_id = @qid WHERE cote = @cote;
    SELECT @cote AS cote, @modele AS modele,
           N'Feuille ' + @cote + N' ouverte pour la question ' + @reference + N', gabarit ' + @modele + N'. Exportez-la, remplissez-la, redéposez-la.' AS message;
END;

GO

