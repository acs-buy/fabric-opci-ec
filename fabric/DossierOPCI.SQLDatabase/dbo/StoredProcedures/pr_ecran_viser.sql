
-- pr_ecran_viser aiguille aussi CYCLE et REVUE : objet_ref « entite|arrete|cycle » et « entite|arrete ».
CREATE   PROCEDURE dbo.pr_ecran_viser
    @nature     varchar(20),
    @objet_ref  varchar(60),
    @decision   varchar(8),
    @decide_par nvarchar(200),
    @motif      nvarchar(600) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- 15/10/2026 : une personne vide ou NULL se refuse en francais, avant tout le reste
    IF NULLIF(LTRIM(RTRIM(@decide_par)), N'') IS NULL
        THROW 50105, N'Visa refusé : votre compte ne tient pas, sur ce dossier, le rôle habilité à viser cet objet.', 1;
    -- 327 debut (24/10/2026) : un champ vide se refuse en francais avant toute ecriture, au texte du champ dans le
    -- plan de l'etude des fonctions (decision A du candidat). Genere par 61_DEPLOIEMENT/generer_327_refus_champs_vides.py.
    -- Place : apres le refus de la personne vide (50105) ; le renvoi d'une publication garde son refus 50101.
    -- le vide : les 29 caracteres de str.isspace(), compares au point de code
    DECLARE @r327_blancs NVARCHAR (29) = NCHAR(9) + NCHAR(10) + NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(28) + NCHAR(29) + NCHAR(30) + NCHAR(31) + NCHAR(32)
        + NCHAR(133) + NCHAR(160) + NCHAR(5760) + NCHAR(8192) + NCHAR(8193) + NCHAR(8194) + NCHAR(8195) + NCHAR(8196) + NCHAR(8197) + NCHAR(8198)
        + NCHAR(8199) + NCHAR(8200) + NCHAR(8201) + NCHAR(8202) + NCHAR(8232) + NCHAR(8233) + NCHAR(8239) + NCHAR(8287) + NCHAR(12288);
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @objet_ref COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51230, N'Visa refusé : l''écran ne désigne aucun objet à viser ; l''action n''est pas exécutée.', 1;
    IF @nature <> 'PUBLICATION' AND @decision = 'RENVOYE' AND ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @motif COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51225, N'Renvoi refusé : un renvoi porte son motif. Sans lui, le préparateur ne sait pas ce qu''il doit corriger.', 1;
    -- 327 fin
    DECLARE @p1 int = CHARINDEX('|', @objet_ref);
    DECLARE @p2 int = CASE WHEN @p1 > 0 THEN CHARINDEX('|', @objet_ref, @p1 + 1) ELSE 0 END;
    IF @nature = 'CONCLUSION'
        EXEC dbo.pr_ecran_viser_conclusion @objet_ref, @decision, @decide_par, @motif;
    ELSE IF @nature = 'DEROGATION'
        EXEC dbo.pr_ecran_viser_derogation @derogation_id = @objet_ref, @decision = @decision, @decide_par = @decide_par, @motif = @motif;
    ELSE IF @nature = 'EVALUATION'
        EXEC dbo.pr_ecran_viser_evaluation @evaluation_id = @objet_ref, @decision = @decision, @decide_par = @decide_par, @motif = @motif;
    ELSE IF @nature = 'LOT'
        EXEC dbo.pr_ecran_viser_lot @lot_id = @objet_ref, @decision = @decision, @decide_par = @decide_par, @motif = @motif;
    ELSE IF @nature = 'CYCLE'
    BEGIN
        IF @p2 = 0 THROW 50103, N'Visa refusé : la référence d''un cycle s''écrit « entité|arrêté|cycle ».', 1;
        DECLARE @ce varchar(20) = LEFT(@objet_ref, @p1 - 1), @ca varchar(20) = SUBSTRING(@objet_ref, @p1 + 1, @p2 - @p1 - 1),
                @cc varchar(10) = SUBSTRING(@objet_ref, @p2 + 1, 10);
        EXEC dbo.pr_viser_cycle @ce, @ca, @cc, @decision, @decide_par, @motif;
    END
    ELSE IF @nature = 'REVUE'
    BEGIN
        IF @p1 = 0 THROW 50104, N'Visa refusé : la référence d''une revue s''écrit « entité|arrêté ».', 1;
        DECLARE @re varchar(20) = LEFT(@objet_ref, @p1 - 1), @ra varchar(20) = SUBSTRING(@objet_ref, @p1 + 1, 40);
        EXEC dbo.pr_viser_revue @re, @ra, @decision, @decide_par, @motif;
    END
    ELSE IF @nature = 'PUBLICATION'
    BEGIN
        IF @decision <> 'VISE'
            THROW 50101, N'Renvoi refusé : une publication de valeur liquidative se vise ou reste en attente, elle ne se renvoie pas.', 1;
        IF @p1 = 0
            THROW 50102, N'Visa refusé : la référence d''une publication s''écrit « entité|arrêté ».', 1;
        DECLARE @e varchar(20) = LEFT(@objet_ref, @p1 - 1), @a varchar(20) = SUBSTRING(@objet_ref, @p1 + 1, 40);
        EXEC dbo.pr_ecran_publier_vl @entite = @e, @arrete = @a, @par = @decide_par;
    END
    ELSE
        THROW 50100, N'Visa refusé : nature inconnue. Les natures visables sont la conclusion, la dérogation, l''évaluation, le lot, la publication, le cycle et la revue.', 1;
END;

GO

