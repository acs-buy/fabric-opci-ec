


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
    -- LA GARDE DE L'EQUIPE : une personne qui tient un role de mission sur l'entite, au jour de la conclusion.
    IF dbo.fn_tient_role_mission(@entite, @par, CAST(SYSUTCDATETIME() AS DATE)) = 0
    BEGIN
        DECLARE @m_role NVARCHAR (400) = N'Conclusion refusée : cette personne ne tient aucun rôle de mission sur l''entité ' + @entite + N' ; le cycle se conclut par l''équipe de la mission.';
        THROW 50639, @m_role, 1;
    END;
    DECLARE @m NVARCHAR (400);
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_cycle WHERE code = @cycle)
        THROW 50321, N'Le cycle désigné n''existe pas.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @entite AND forme_vehicule IS NOT NULL)
    BEGIN
        SET @m = N'Conclusion refusée : l''entité ' + ISNULL(@entite, N'vide') + N' n''est pas un véhicule ; la revue porte sur le véhicule et couvre ses filiales.';
        THROW 50520, @m, 1;
    END;
    IF NOT EXISTS (SELECT 1 FROM dbo.arrete_mission WHERE entite = @entite AND arrete = @arrete)
        THROW 50322, N'Un cycle se conclut sur un arrêté ouvert.', 1;
    IF dbo.fn_cycle_au_programme(@entite, @arrete, @cycle) = 0
    BEGIN
        SET @m = N'Conclusion refusée : le cycle ' + @cycle + N' n''est pas au programme de cet arrêté.';
        THROW 50519, @m, 1;
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

