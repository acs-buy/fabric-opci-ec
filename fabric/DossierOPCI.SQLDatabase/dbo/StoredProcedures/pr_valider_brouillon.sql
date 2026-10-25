
-- pr_valider_brouillon : l'enveloppe (regle unique, lot B2, enveloppe)
CREATE   PROCEDURE dbo.pr_valider_brouillon
    @entite       VARCHAR (20),
    @arrete       VARCHAR (20),
    @feuille_cote VARCHAR (30),
    @question_id  INT,
    @valide_par   NVARCHAR (200)
    , @calculer BIT = 0   -- regle unique : 1 pour calculer les vehicules touches ; par defaut, la marque de retard seule
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    -- 327 debut (24/10/2026) : un champ vide se refuse en francais avant toute ecriture, au texte du champ dans le
    -- plan de l'etude des fonctions (decision A du candidat). Genere par 61_DEPLOIEMENT/generer_327_refus_champs_vides.py.
    -- Place : avant le TRY de l'enveloppe.
    -- le vide : les 29 caracteres de str.isspace(), compares au point de code
    DECLARE @r327_blancs NVARCHAR (29) = NCHAR(9) + NCHAR(10) + NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(28) + NCHAR(29) + NCHAR(30) + NCHAR(31) + NCHAR(32)
        + NCHAR(133) + NCHAR(160) + NCHAR(5760) + NCHAR(8192) + NCHAR(8193) + NCHAR(8194) + NCHAR(8195) + NCHAR(8196) + NCHAR(8197) + NCHAR(8198)
        + NCHAR(8199) + NCHAR(8200) + NCHAR(8201) + NCHAR(8202) + NCHAR(8232) + NCHAR(8233) + NCHAR(8239) + NCHAR(8287) + NCHAR(12288);
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @entite COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51201, N'Choisissez le véhicule dans le sélecteur Véhicule.', 1;
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @arrete COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51202, N'Choisissez l''arrêté dans le sélecteur Arrêté.', 1;
    IF @question_id IS NULL OR ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @feuille_cote COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51203, N'Choisissez la question dans la grille « Questions du cycle ».', 1;
    -- 327 fin
    DECLARE @ann_tc INT = @@TRANCOUNT, @ann_journal INT = ISNULL((SELECT MAX(id) FROM dbo.journal_refus), 0),
            @ann_e VARCHAR (20), @ann_par NVARCHAR (400) = @valide_par;
    DECLARE @ann_v TABLE (entite VARCHAR (20) PRIMARY KEY, verrou TINYINT NOT NULL DEFAULT 0);   -- 0 a verrouiller, 1 verrouille, 2 calcule
    DECLARE @ann_j TABLE (id INT, procedure_nom VARCHAR (MAX), entite VARCHAR (MAX), arrete VARCHAR (MAX), cote VARCHAR (MAX), message NVARCHAR (MAX),
                          refuse_pour NVARCHAR (MAX), refuse_le DATETIME2, question_reference VARCHAR (MAX), geste NVARCHAR (MAX));
    BEGIN TRY
    BEGIN TRANSACTION;
    -- 1. les vehicules que l'ecriture touche, verrouilles dans l'ordre binaire avant toute garde
    INSERT INTO @ann_v (entite)
    SELECT DISTINCT v.entite FROM (SELECT @entite AS x, CAST(0 AS BIT) AS lecteurs) e CROSS APPLY dbo.fn_ann_vehicules(e.x, e.lecteurs, NULL) v;
    WHILE 1 = 1
    BEGIN
        SET @ann_e = (SELECT TOP (1) entite FROM @ann_v WHERE verrou = 0 ORDER BY CAST(entite AS NVARCHAR (20)) COLLATE Latin1_General_100_BIN2);
        IF @ann_e IS NULL BREAK;
        EXEC dbo.pr_ann_verrou @entite = @ann_e;
        UPDATE @ann_v SET verrou = 1 WHERE entite = @ann_e;
    END;
    -- 2. le corps d'origine
    EXEC dbo.pr_valider_brouillon_corps @entite = @entite, @arrete = @arrete, @feuille_cote = @feuille_cote, @question_id = @question_id, @valide_par = @valide_par;
    -- 3. un calcul par vehicule, par la procedure la plus externe
    IF @calculer = 1
    BEGIN
        INSERT INTO @ann_v (entite)
        SELECT DISTINCT v.entite FROM (SELECT @entite AS x, CAST(0 AS BIT) AS lecteurs) e CROSS APPLY dbo.fn_ann_vehicules(e.x, e.lecteurs, NULL) v
        WHERE NOT EXISTS (SELECT 1 FROM @ann_v w WHERE w.entite = v.entite);
        WHILE 1 = 1
        BEGIN
            SET @ann_e = (SELECT TOP (1) entite FROM @ann_v WHERE verrou < 2 ORDER BY CAST(entite AS NVARCHAR (20)) COLLATE Latin1_General_100_BIN2);
            IF @ann_e IS NULL BREAK;
            EXEC dbo.pr_ann_verrou @entite = @ann_e;
            EXEC dbo.pr_calculer_annexe @entite = @ann_e, @arrete = NULL, @declencheur = 'SOURCE', @par = @ann_par, @rendre = 0;
            UPDATE @ann_v SET verrou = 2 WHERE entite = @ann_e;
        END;
    END;
    COMMIT;
    END TRY
    BEGIN CATCH
        IF @ann_tc = 0 AND @@TRANCOUNT > 0
        BEGIN
            -- appel direct : les lignes de journal que le corps a ecrites avant son refus survivent a l'annulation
            INSERT INTO @ann_j SELECT id, procedure_nom, entite, arrete, cote, message, refuse_pour, refuse_le, question_reference, geste
            FROM dbo.journal_refus WHERE id > @ann_journal;
            ROLLBACK TRANSACTION;
            INSERT INTO dbo.journal_refus (procedure_nom, entite, arrete, cote, message, refuse_pour, refuse_le, question_reference, geste)
            SELECT procedure_nom, entite, arrete, cote, message, refuse_pour, refuse_le, question_reference, geste FROM @ann_j j
            WHERE NOT EXISTS (SELECT 1 FROM dbo.journal_refus r WHERE r.id = j.id) ORDER BY j.id;
        END;
        THROW;
    END CATCH;
END;

GO

