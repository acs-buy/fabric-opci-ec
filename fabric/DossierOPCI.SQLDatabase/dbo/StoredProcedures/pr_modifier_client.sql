
-- pr_modifier_client : l'enveloppe (regle unique, lot B2, enveloppe)
CREATE   PROCEDURE dbo.pr_modifier_client
    @code               VARCHAR (20),
    @denomination       NVARCHAR (400) = NULL,
    @siren              CHAR (9)       = NULL,
    @forme_vehicule     VARCHAR (10)   = NULL,
    @forme_sociale      VARCHAR (10)   = NULL,
    @adresse_1          NVARCHAR (400) = NULL,
    @adresse_2          NVARCHAR (400) = NULL,
    @code_postal        VARCHAR (10)   = NULL,
    @ville              NVARCHAR (200) = NULL,
    @pays               CHAR (2)       = NULL,
    @dirigeant_nom      NVARCHAR (400) = NULL,
    @dirigeant_qualite  VARCHAR (60)   = NULL,
    @contact_nom        NVARCHAR (400) = NULL,
    @contact_courriel   NVARCHAR (400) = NULL,
    @contact_telephone  VARCHAR (30)   = NULL,
    @cloture            CHAR (5)       = NULL,
    @site_url           NVARCHAR (800) = NULL,
    @par                NVARCHAR (400)
    , @calculer BIT = 0   -- regle unique : 1 pour calculer les vehicules touches ; par defaut, la marque de retard seule
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @ann_tc INT = @@TRANCOUNT, @ann_journal INT = ISNULL((SELECT MAX(id) FROM dbo.journal_refus), 0),
            @ann_e VARCHAR (20), @ann_par NVARCHAR (400) = @par;
    DECLARE @ann_v TABLE (entite VARCHAR (20) PRIMARY KEY, verrou TINYINT NOT NULL DEFAULT 0);   -- 0 a verrouiller, 1 verrouille, 2 calcule
    DECLARE @ann_j TABLE (id INT, procedure_nom VARCHAR (MAX), entite VARCHAR (MAX), arrete VARCHAR (MAX), cote VARCHAR (MAX), message NVARCHAR (MAX),
                          refuse_pour NVARCHAR (MAX), refuse_le DATETIME2, question_reference VARCHAR (MAX), geste NVARCHAR (MAX));
    BEGIN TRY
    BEGIN TRANSACTION;
    -- 1. les vehicules que l'ecriture touche, verrouilles dans l'ordre binaire avant toute garde
    INSERT INTO @ann_v (entite)
    SELECT DISTINCT v.entite FROM (SELECT @code AS x, CAST(1 AS BIT) AS lecteurs) e CROSS APPLY dbo.fn_ann_vehicules(e.x, e.lecteurs, NULL) v;
    WHILE 1 = 1
    BEGIN
        SET @ann_e = (SELECT TOP (1) entite FROM @ann_v WHERE verrou = 0 ORDER BY CAST(entite AS NVARCHAR (20)) COLLATE Latin1_General_100_BIN2);
        IF @ann_e IS NULL BREAK;
        EXEC dbo.pr_ann_verrou @entite = @ann_e;
        UPDATE @ann_v SET verrou = 1 WHERE entite = @ann_e;
    END;
    -- 2. le corps d'origine
    EXEC dbo.pr_modifier_client_corps @code = @code, @denomination = @denomination, @siren = @siren, @forme_vehicule = @forme_vehicule, @forme_sociale = @forme_sociale, @adresse_1 = @adresse_1, @adresse_2 = @adresse_2, @code_postal = @code_postal, @ville = @ville, @pays = @pays, @dirigeant_nom = @dirigeant_nom, @dirigeant_qualite = @dirigeant_qualite, @contact_nom = @contact_nom, @contact_courriel = @contact_courriel, @contact_telephone = @contact_telephone, @cloture = @cloture, @site_url = @site_url, @par = @par;
    -- 3. un calcul par vehicule, par la procedure la plus externe
    IF @calculer = 1
    BEGIN
        INSERT INTO @ann_v (entite)
        SELECT DISTINCT v.entite FROM (SELECT @code AS x, CAST(1 AS BIT) AS lecteurs) e CROSS APPLY dbo.fn_ann_vehicules(e.x, e.lecteurs, NULL) v
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

