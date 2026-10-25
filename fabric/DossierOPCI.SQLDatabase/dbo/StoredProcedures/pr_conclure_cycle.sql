
-- pr_conclure_cycle : 3 refus
-- 6. CONCLURE UN CYCLE : un cycle au programme d'un vehicule, admis depuis A_CONCLURE,
-- CONCLU et RENVOYE. La synthese et le compte des feuilles lisent le perimetre.
CREATE   PROCEDURE dbo.pr_conclure_cycle
    @entite      VARCHAR (20),
    @arrete      VARCHAR (20),
    @cycle       VARCHAR (10),
    @conclusion  NVARCHAR (2000),
    @forme       VARCHAR (20)   = NULL,
    @par         NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    -- 327 debut (24/10/2026) : un champ vide se refuse en francais avant toute ecriture, au texte du champ dans le
    -- plan de l'etude des fonctions (decision A du candidat). Genere par 61_DEPLOIEMENT/generer_327_refus_champs_vides.py.
    -- Place : les selecteurs passent devant la garde de droit, qui se juge sur eux.
    -- le vide : les 29 caracteres de str.isspace(), compares au point de code
    DECLARE @r327_blancs NVARCHAR (29) = NCHAR(9) + NCHAR(10) + NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(28) + NCHAR(29) + NCHAR(30) + NCHAR(31) + NCHAR(32)
        + NCHAR(133) + NCHAR(160) + NCHAR(5760) + NCHAR(8192) + NCHAR(8193) + NCHAR(8194) + NCHAR(8195) + NCHAR(8196) + NCHAR(8197) + NCHAR(8198)
        + NCHAR(8199) + NCHAR(8200) + NCHAR(8201) + NCHAR(8202) + NCHAR(8232) + NCHAR(8233) + NCHAR(8239) + NCHAR(8287) + NCHAR(12288);
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @entite COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51201, N'Choisissez le véhicule dans le sélecteur Véhicule.', 1;
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @arrete COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51202, N'Choisissez l''arrêté dans le sélecteur Arrêté.', 1;
    -- 327 fin
    -- LA GARDE DE L'EQUIPE : une personne qui tient un role de mission sur l'entite, au jour de la conclusion.
    IF dbo.fn_tient_role_mission(@entite, @par, CAST(SYSUTCDATETIME() AS DATE)) = 0
    BEGIN
        DECLARE @m_role NVARCHAR (400) = N'Conclusion refusée : cette personne ne tient aucun rôle de mission sur l''entité ' + @entite + N' ; le cycle se conclut par l''équipe de la mission.';
        BEGIN SET @m_role = REPLACE(@m_role, N'%', N'%%'); THROW 50639, @m_role, 1; END
    END;
    -- 327 debut (24/10/2026) : un champ vide se refuse en francais avant toute ecriture, au texte du champ dans le
    -- plan de l'etude des fonctions (decision A du candidat). Genere par 61_DEPLOIEMENT/generer_327_refus_champs_vides.py.
    -- Place : apres la garde de droit.
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @cycle COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51210, N'Conclusion refusée : choisissez le cycle dans la bande des cycles ; un cycle se conclut sur un arrêté ouvert, dossier de travail non verrouillé, tant que ni lui ni la revue ne sont visés.', 1;
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @conclusion COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51236, N'Champs obligatoires à remplir : « Conclusion du cycle ».', 1;
    -- 327 fin
    DECLARE @m NVARCHAR (400);
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_cycle WHERE code = @cycle)
        THROW 50321, N'Le cycle désigné n''existe pas.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @entite AND forme_vehicule IS NOT NULL)
    BEGIN
        SET @m = N'Conclusion refusée : l''entité ' + ISNULL(@entite, N'vide') + N' n''est pas un véhicule ; la revue porte sur le véhicule et couvre ses filiales.';
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50520, @m, 1; END
    END;
    IF NOT EXISTS (SELECT 1 FROM dbo.arrete_mission WHERE entite = @entite AND arrete = @arrete)
        THROW 50322, N'Un cycle se conclut sur un arrêté ouvert.', 1;
    IF dbo.fn_cycle_au_programme(@entite, @arrete, @cycle) = 0
    BEGIN
        SET @m = N'Conclusion refusée : le cycle ' + @cycle + N' n''est pas au programme de cet arrêté.';
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50519, @m, 1; END
    END;
    IF NULLIF(LTRIM(RTRIM(@conclusion)), N'') IS NULL
        THROW 50323, N'La conclusion du cycle est un texte : ce qui a été vu de bloquant, ce qui a été vu de satisfaisant.', 1;
    IF dbo.fn_dossier_verrouille(@entite, @arrete) = 1
        THROW 50303, N'Le dossier de cet arrêté est visé et verrouillé ; le déverrouiller avant de conclure à nouveau.', 1;
    IF dbo.fn_revue_visee(@entite, @arrete) = 1
        THROW 50509, N'Refusé : la revue de cet arrêté est visée ; déverrouiller le dossier avant de rouvrir un cycle.', 1;
    IF dbo.fn_etat_cycle(@entite, @arrete, @cycle) = 'VISE'
        THROW 50324, N'Ce cycle est déjà visé ; sa conclusion ne se modifie plus.', 1;

    DECLARE @synthese NVARCHAR (MAX) = dbo.fn_synthese_feuilles(@entite, @arrete, @cycle);
    IF EXISTS (SELECT 1 FROM dbo.conclusion_cycle WHERE entite = @entite AND arrete = @arrete AND cycle = @cycle)
        UPDATE dbo.conclusion_cycle
           SET synthese_feuilles = @synthese, conclusion = @conclusion, forme = @forme, conclu_par = @par, conclu_le = SYSUTCDATETIME()
         WHERE entite = @entite AND arrete = @arrete AND cycle = @cycle;
    ELSE
        INSERT INTO dbo.conclusion_cycle (entite, arrete, cycle, synthese_feuilles, conclusion, forme, conclu_par)
        VALUES (@entite, @arrete, @cycle, @synthese, @conclusion, @forme, @par);

    DECLARE @n INT = (SELECT COUNT(*) FROM dbo.v_feuilles_du_cycle WHERE vehicule = @entite AND arrete = @arrete AND cycle = @cycle);
    SELECT @cycle AS cycle, @n AS feuilles, @synthese AS synthese_feuilles,
           N'Cycle ' + @cycle + N' conclu, synthèse de ' + CAST(@n AS NVARCHAR (10)) + N' feuille(s) régénérée. Le visa du chef de mission peut être demandé.' AS message;
END;

GO

