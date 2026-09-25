-- 213. Le site SharePoint du client, enregistre par le reviseur depuis la fiche du dossier.
-- Regle du candidat, 19/09/2026 : « dans le formulaire de saisie du nouveau client, il doit y avoir un endroit
-- pour indiquer le lien vers le site SharePoint qui a ete cree. Le site SharePoint doit etre cree manuellement
-- par l'utilisateur, via une equipe Teams ; il prend le lien du site et vient nous le mettre la. »
-- Architecture 21_ARCHITECTURE_DATA_V2.md, ligne 96 : les pieces vivent dans SharePoint, le coffre OneLake
-- n'en porte qu'un raccourci sans copie.
--
-- La table dbo.demande_espace_client (script du 08/09/2026) porte deja site_url, statut et l'historique ;
-- pr_ecran_provisionner_espace y ecrit la voie AUTOMATIQUE (fonction Azure qui cree l'equipe et le site).
-- Ce script ajoute la voie MANUELLE, celle que le candidat demande, sans toucher a l'automatique :
--   1. pr_enregistrer_site_client : une ligne FAIT, source MANUEL, avec l'URL collee ; rejouable (meme URL =
--      rien de nouveau) ; l'URL doit commencer par https:// et porter sharepoint.com.
--   2. pr_creer_client et pr_modifier_client prennent @site_url (facultatif) et l'enregistrent dans le
--      meme geste. Leurs definitions des scripts 211 et 212 sont REMPLACEES ici, a l'identique par ailleurs.
-- Lecture a l'ecran : v_espace_client (entite, statut, site_url, equipe_indice), 1 ligne par entite.
-- Prerequis : 211, 212. Rejouable.

CREATE   PROCEDURE dbo.pr_enregistrer_site_client
    @entite    VARCHAR (20),
    @site_url  NVARCHAR (800),
    @par       NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @entite AND est_client = 1)
        THROW 50281, N'Le site SharePoint se rattache à un client du cabinet.', 1;
    SET @site_url = NULLIF(LTRIM(RTRIM(@site_url)), N'');
    IF @site_url IS NULL
        THROW 50282, N'Le lien du site SharePoint est vide.', 1;
    IF LEFT(LOWER(@site_url), 8) <> N'https://' OR CHARINDEX(N'sharepoint.com/', LOWER(@site_url)) = 0
        THROW 50283, N'Le lien attendu est celui du site SharePoint de l''équipe Teams, de la forme https://<cabinet>.sharepoint.com/sites/<nom>.', 1;
    SET @site_url = CASE WHEN RIGHT(@site_url, 1) = N'/' THEN LEFT(@site_url, LEN(@site_url) - 1) ELSE @site_url END;

    DECLARE @actuel NVARCHAR (800) = (SELECT TOP (1) site_url FROM dbo.demande_espace_client
                                      WHERE entite = @entite ORDER BY id DESC);
    IF @actuel = @site_url
    BEGIN
        SELECT @entite AS entite, @site_url AS site_url, N'Le site SharePoint de ' + @entite + N' était déjà enregistré.' AS message;
        RETURN;
    END;
    INSERT INTO dbo.demande_espace_client
        (entite, demande_par, demande_le, equipe_teams, statut, site_url, reponse, repondu_le)
    VALUES
        (@entite, @par, SYSUTCDATETIME(), 1, 'FAIT', @site_url,
         N'{"source":"MANUEL","note":"site cree par le reviseur via Teams, lien colle dans la fiche du dossier"}', SYSUTCDATETIME());
    SELECT @entite AS entite, @site_url AS site_url,
           N'Site SharePoint de ' + @entite + N' enregistré' + CASE WHEN @actuel IS NULL THEN N'.' ELSE N', il remplace le précédent.' END AS message;
END;

GO

