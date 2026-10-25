
-- pr_repondre_question : 7 refus
-- --- 9. pr_repondre_question, meme corps qu'au 205, plus la garde du verrou ----------------------
CREATE   PROCEDURE dbo.pr_repondre_question
    @cote                  VARCHAR (30),
    @reference             VARCHAR (20),
    @reponse               NVARCHAR (400) = NULL,
    @motif_non_applicable  NVARCHAR (800) = NULL,
    @commentaire           NVARCHAR (2000) = NULL,
    @par                   NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    -- 327 debut (24/10/2026) : un champ vide se refuse en francais avant toute ecriture, au texte du champ dans le
    -- plan de l'etude des fonctions (decision A du candidat). Genere par 61_DEPLOIEMENT/generer_327_refus_champs_vides.py.
    -- Place : fn_ecran_client.repondre_question refuse ces champs avant l'appel.
    -- le vide : les 29 caracteres de str.isspace(), compares au point de code
    DECLARE @r327_blancs NVARCHAR (29) = NCHAR(9) + NCHAR(10) + NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(28) + NCHAR(29) + NCHAR(30) + NCHAR(31) + NCHAR(32)
        + NCHAR(133) + NCHAR(160) + NCHAR(5760) + NCHAR(8192) + NCHAR(8193) + NCHAR(8194) + NCHAR(8195) + NCHAR(8196) + NCHAR(8197) + NCHAR(8198)
        + NCHAR(8199) + NCHAR(8200) + NCHAR(8201) + NCHAR(8202) + NCHAR(8232) + NCHAR(8233) + NCHAR(8239) + NCHAR(8287) + NCHAR(12288);
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @reference COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51203, N'Choisissez la question dans la grille « Questions du cycle ».', 1;
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @cote COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51213, N'Réponse refusée : la question choisie n''est rattachée à aucune feuille de questions de cet arrêté.', 1;
    -- 327 fin
    DECLARE @qid INT, @type VARCHAR (20), @options NVARCHAR (200), @entite VARCHAR (20), @arrete VARCHAR (20);
    SELECT @qid = q.id, @type = q.type_reponse, @options = q.options FROM dbo.ref_question q WHERE q.reference = @reference;
    IF @qid IS NULL
        THROW 50241, N'La question désignée n''existe pas au référentiel.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.feuille_question WHERE cote = @cote AND question_id = @qid)
    BEGIN
        DECLARE @m1 NVARCHAR (400) = N'La question ' + @reference + N' n''est pas au questionnaire ' + @cote + N'.';
        BEGIN SET @m1 = REPLACE(@m1, N'%', N'%%'); THROW 50242, @m1, 1; END
    END;
    SELECT @entite = entite, @arrete = arrete FROM dbo.feuille_travail WHERE cote = @cote;
    IF EXISTS (SELECT 1 FROM dbo.feuille_travail WHERE cote = @cote AND conclue_le IS NOT NULL)
        THROW 50243, N'Ce questionnaire est conclu : il ne se modifie plus sans reprise.', 1;
    IF dbo.fn_dossier_verrouille(@entite, @arrete) = 1
        THROW 50303, N'Le dossier de cet arrêté est visé et verrouillé : il s''exporte, il ne se modifie plus. Seule la personne qui a visé peut le déverrouiller.', 1;

    SET @reponse = NULLIF(LTRIM(RTRIM(@reponse)), N'');
    DECLARE @bin VARCHAR (20) = NULL, @val NVARCHAR (400) = NULL;
    IF @reponse IS NULL
    BEGIN
        UPDATE dbo.feuille_question
           SET reponse = NULL, reponse_valeur = NULL, motif_non_applicable = NULL,
               commentaire = @commentaire, repondu_par = NULL, repondu_le = NULL
         WHERE cote = @cote AND question_id = @qid;
        RETURN;
    END;
    IF @type IN ('OUI_NON', 'OUI_NON_NA')
    BEGIN
        SET @bin = CASE UPPER(@reponse) WHEN N'OUI' THEN 'OUI' WHEN N'NON' THEN 'NON'
                       WHEN N'NON_APPLICABLE' THEN 'NON_APPLICABLE' WHEN N'NA' THEN 'NON_APPLICABLE' WHEN N'N/A' THEN 'NON_APPLICABLE' END;
        IF @bin IS NULL
        BEGIN
            DECLARE @m2 NVARCHAR (400) = N'La question ' + @reference + N' se répond par OUI ou NON'
                + CASE WHEN @type = 'OUI_NON_NA' THEN N', ou NA avec un motif' ELSE N'' END + N'. Reçu : « ' + @reponse + N' ».';
            BEGIN SET @m2 = REPLACE(@m2, N'%', N'%%'); THROW 50244, @m2, 1; END
        END;
        IF @bin = 'NON_APPLICABLE' AND @type = 'OUI_NON'
        BEGIN
            DECLARE @m3 NVARCHAR (400) = N'La question ' + @reference + N' n''admet pas la non-applicabilité.';
            BEGIN SET @m3 = REPLACE(@m3, N'%', N'%%'); THROW 50245, @m3, 1; END
        END;
        IF @bin = 'NON_APPLICABLE' AND NULLIF(LTRIM(RTRIM(@motif_non_applicable)), N'') IS NULL
        BEGIN
            DECLARE @m4 NVARCHAR (400) = N'La question ' + @reference + N' est déclarée non applicable sans motif. Le motif est obligatoire.';
            BEGIN SET @m4 = REPLACE(@m4, N'%', N'%%'); THROW 50246, @m4, 1; END
        END;
    END
    ELSE
    BEGIN
        SET @val = @reponse;
        IF @type = 'CHOIX' AND @options IS NOT NULL
           AND NOT EXISTS (SELECT 1 FROM STRING_SPLIT(@options, '|') s WHERE LTRIM(RTRIM(s.value)) = @val)
        BEGIN
            DECLARE @m5 NVARCHAR (600) = N'La question ' + @reference + N' se répond parmi : ' + REPLACE(@options, '|', N', ') + N'. Reçu : « ' + @val + N' ».';
            BEGIN SET @m5 = REPLACE(@m5, N'%', N'%%'); THROW 50247, @m5, 1; END
        END;
        IF @type = 'DATE' AND TRY_CONVERT(DATE, @val, 103) IS NULL AND TRY_CONVERT(DATE, @val, 23) IS NULL
        BEGIN
            DECLARE @m6 NVARCHAR (400) = N'La question ' + @reference + N' attend une date, jj/mm/aaaa. Reçu : « ' + @val + N' ».';
            BEGIN SET @m6 = REPLACE(@m6, N'%', N'%%'); THROW 50248, @m6, 1; END
        END;
        IF @type = 'MONTANT' AND TRY_CONVERT(DECIMAL (18, 2), REPLACE(REPLACE(@val, N' ', N''), N',', N'.')) IS NULL
        BEGIN
            DECLARE @m7 NVARCHAR (400) = N'La question ' + @reference + N' attend un montant. Reçu : « ' + @val + N' ».';
            BEGIN SET @m7 = REPLACE(@m7, N'%', N'%%'); THROW 50249, @m7, 1; END
        END;
    END;
    UPDATE dbo.feuille_question
       SET reponse = @bin, reponse_valeur = @val,
           motif_non_applicable = CASE WHEN @bin = 'NON_APPLICABLE' THEN @motif_non_applicable END,
           commentaire = @commentaire, repondu_par = @par, repondu_le = SYSUTCDATETIME()
     WHERE cote = @cote AND question_id = @qid;
END;

GO

