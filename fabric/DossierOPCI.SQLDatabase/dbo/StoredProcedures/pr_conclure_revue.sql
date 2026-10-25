
-- pr_conclure_revue : 2 refus
-- 8. CONCLURE LA REVUE : un vehicule ; admis depuis A_CONCLURE, CONCLUE et RENVOYEE.
CREATE   PROCEDURE dbo.pr_conclure_revue
    @entite      VARCHAR (20),
    @arrete      VARCHAR (20),
    @conclusion  NVARCHAR (4000),
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
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @arrete COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51202, N'Choisissez l''arrêté dans le sélecteur Arrêté.', 1;
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @entite COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51211, N'Conclusion refusée : aucune revue à conclure pour le véhicule et l''arrêté des sélecteurs : la revue est visée, le dossier de travail est verrouillé, ou l''arrêté n''a pas de revue.', 1;
    -- 327 fin
    -- LA GARDE DE L'EQUIPE : une personne qui tient un role de mission sur l'entite, au jour de la conclusion.
    IF dbo.fn_tient_role_mission(@entite, @par, CAST(SYSUTCDATETIME() AS DATE)) = 0
    BEGIN
        DECLARE @m_role NVARCHAR (400) = N'Conclusion refusée : cette personne ne tient aucun rôle de mission sur l''entité ' + @entite + N' ; la revue se conclut par l''équipe de la mission.';
        BEGIN SET @m_role = REPLACE(@m_role, N'%', N'%%'); THROW 50639, @m_role, 1; END
    END;
    -- 327 debut (24/10/2026) : un champ vide se refuse en francais avant toute ecriture, au texte du champ dans le
    -- plan de l'etude des fonctions (decision A du candidat). Genere par 61_DEPLOIEMENT/generer_327_refus_champs_vides.py.
    -- Place : apres la garde de droit.
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @conclusion COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51237, N'Champs obligatoires à remplir : « Conclusion générale de la revue ».', 1;
    -- 327 fin
    DECLARE @m NVARCHAR (400);
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @entite AND forme_vehicule IS NOT NULL)
    BEGIN
        SET @m = N'Conclusion refusée : l''entité ' + ISNULL(@entite, N'vide') + N' n''est pas un véhicule ; la revue porte sur le véhicule et couvre ses filiales.';
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50520, @m, 1; END
    END;
    IF NOT EXISTS (SELECT 1 FROM dbo.arrete_mission WHERE entite = @entite AND arrete = @arrete)
        THROW 50322, N'La revue se conclut sur un arrêté ouvert.', 1;
    IF NULLIF(LTRIM(RTRIM(@conclusion)), N'') IS NULL
        THROW 50323, N'La conclusion générale est un texte.', 1;
    IF dbo.fn_dossier_verrouille(@entite, @arrete) = 1
        THROW 50303, N'Le dossier de cet arrêté est visé et verrouillé ; le déverrouiller avant de conclure à nouveau.', 1;
    IF dbo.fn_etat_revue(@entite, @arrete) = 'VISEE'
        THROW 50510, N'Conclusion refusée : la revue est visée ; déverrouiller le dossier avant de la reconclure.', 1;
    IF EXISTS (SELECT 1 FROM dbo.conclusion_revue WHERE entite = @entite AND arrete = @arrete)
        UPDATE dbo.conclusion_revue SET conclusion = @conclusion, conclu_par = @par, conclu_le = SYSUTCDATETIME()
         WHERE entite = @entite AND arrete = @arrete;
    ELSE
        INSERT INTO dbo.conclusion_revue (entite, arrete, conclusion, conclu_par) VALUES (@entite, @arrete, @conclusion, @par);
    DECLARE @cycles INT = (SELECT COUNT(*) FROM dbo.ref_cycle c WHERE dbo.fn_cycle_au_programme(@entite, @arrete, c.code) = 1);
    DECLARE @conclus INT = (SELECT COUNT(*) FROM dbo.conclusion_cycle c WHERE c.entite = @entite AND c.arrete = @arrete
                            AND dbo.fn_cycle_au_programme(@entite, @arrete, c.cycle) = 1);
    SELECT @conclus AS cycles_conclus, @cycles AS cycles_du_programme,
           N'Revue conclue : ' + CAST(@conclus AS NVARCHAR (10)) + N' cycle(s) conclu(s) sur ' + CAST(@cycles AS NVARCHAR (10)) + N' au programme.' AS message;
END;

GO

