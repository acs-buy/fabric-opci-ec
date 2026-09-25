-- 218. Creer un dossier, c'est en devenir le chef de mission.
--
-- DEFAUT MESURE LE 21/09/2026 AU PARCOURS DE BOUT EN BOUT : le temps 4 ne visait rien. Un client cree a
-- l'ecran ne portait AUCUNE ligne de role_mission, donc [Role du connecte] rendait vide, donc
-- [Superviseur connecte] aussi, et le bouton « Approuver » restait sans parametre. Le dossier etait
-- impossible a viser par celui-la meme qui venait de l'ouvrir.
--
-- Regle metier retenue : celui qui cree le dossier en devient CHEF DE MISSION, a la date du jour. C'est
-- ce que fait un cabinet : le collaborateur qui ouvre le dossier le conduit. L'ASSOCIE SIGNATAIRE, lui,
-- ne se donne pas : il se designe, et cela reste un geste de l'ecran Referentiels.
-- Le maintien et l'acceptation acceptent l'un comme l'autre (mesure [Superviseur connecte]).
--
-- Prerequis : 211, 213. Rejouable : la ligne n'est posee que si le createur n'a pas deja un role vivant.

CREATE   PROCEDURE dbo.pr_creer_client
    @code               VARCHAR (20),
    @denomination       NVARCHAR (400),
    @siren              CHAR (9)       = NULL,
    @forme_vehicule     VARCHAR (10)   = NULL,
    @forme_sociale      VARCHAR (10)   = NULL,
    @adresse_1          NVARCHAR (400),
    @adresse_2          NVARCHAR (400) = NULL,
    @code_postal        VARCHAR (10),
    @ville              NVARCHAR (200),
    @pays               CHAR (2)       = 'FR',
    @dirigeant_nom      NVARCHAR (400),
    @dirigeant_qualite  VARCHAR (60),
    @contact_nom        NVARCHAR (400) = NULL,
    @contact_courriel   NVARCHAR (400) = NULL,
    @contact_telephone  VARCHAR (30)   = NULL,
    @cloture            CHAR (5)       = '31/12',
    @periodicite_vl     VARCHAR (13)   = NULL,
    @site_url           NVARCHAR (800) = NULL,
    @par                NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF @code IS NULL OR LTRIM(RTRIM(@code)) = ''
        THROW 50201, N'Le code du client est obligatoire.', 1;
    IF EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @code)
        THROW 50202, N'Ce code existe déjà. Un client se crée une fois ; pour le modifier, passez par les référentiels.', 1;
    IF @forme_vehicule IS NULL
        THROW 50203, N'Un client est un véhicule : SPPICAV ou FPI. Une filiale s''ajoute depuis le périmètre du client.', 1;
    IF @forme_vehicule = 'FPI' AND (@forme_sociale IS NOT NULL OR @siren IS NOT NULL)
        THROW 50204, N'Un FPI n''a ni forme sociale ni SIREN.', 1;
    IF TRY_CONVERT(DATE, @cloture + '/2001', 103) IS NULL
        THROW 50205, N'La clôture s''écrit jour/mois, par exemple 31/12 ou 30/06.', 1;
    SET @site_url = NULLIF(LTRIM(RTRIM(@site_url)), N'');

    DECLARE @maintenant DATETIME2 (0) = SYSUTCDATETIME();
    DECLARE @cote VARCHAR (30) = 'ACC-' + @code;
    DECLARE @questions INT;

    BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO dbo.ref_entite
        (code, denomination, siren, forme_vehicule, forme_sociale, adresse_1, adresse_2, code_postal,
         ville, pays, dirigeant_nom, dirigeant_qualite, contact_nom, contact_courriel, contact_telephone,
         cloture, modifie_par, modifie_le, plan_propre_en_service, est_client, periodicite_vl, cree_le)
    VALUES
        (@code, @denomination, @siren, @forme_vehicule, @forme_sociale, @adresse_1, @adresse_2, @code_postal,
         @ville, @pays, @dirigeant_nom, @dirigeant_qualite, @contact_nom, @contact_courriel, @contact_telephone,
         @cloture, @par, @maintenant, 0, 1, @periodicite_vl, @maintenant);

    -- CELUI QUI CREE LE DOSSIER LE CONDUIT : sans ce role, personne ne peut viser l'acceptation qu'il
    -- vient d'ouvrir, la mesure [Superviseur connecte] lisant role_mission sur le client courant.
    IF NOT EXISTS (SELECT 1 FROM dbo.role_mission
                    WHERE entite = @code AND connexion = @par AND au IS NULL)
        INSERT INTO dbo.role_mission (entite, role, personne, du, au, pose_par, pose_le, connexion)
        VALUES (@code, 'CHEF_MISSION', @par, CAST(@maintenant AS DATE), NULL,
                N'création du dossier à l''écran', @maintenant, @par);

    EXEC dbo.pr_ouvrir_questionnaire_acceptation @entite = @code, @par = @par;
    SET @questions = (SELECT COUNT(*) FROM dbo.feuille_question WHERE cote = @cote);
    IF @site_url IS NOT NULL
        EXEC dbo.pr_enregistrer_site_client @entite = @code, @site_url = @site_url, @par = @par;
    COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @code AS code, @cote AS cote, @questions AS questions,
           N'Client ' + @code + N' créé, vous en êtes le chef de mission. Questionnaire d''acceptation ouvert : '
         + CAST(@questions AS NVARCHAR (10)) + N' questions.'
         + CASE WHEN @site_url IS NULL THEN N'' ELSE N' Site SharePoint enregistré.' END
         + N' Passez à l''étape 3.' AS message;
END;

GO

