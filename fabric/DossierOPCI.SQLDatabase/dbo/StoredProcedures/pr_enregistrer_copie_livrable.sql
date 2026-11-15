-- LA COPIE D'UN FICHIER VALIDE, tracee apres le visa.
CREATE   PROCEDURE dbo.pr_enregistrer_copie_livrable
    @document_id INT,
    @web_url     NVARCHAR (800),
    @par         NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @entite VARCHAR (20), @arrete VARCHAR (20), @m NVARCHAR (400);
    SELECT @entite = entite, @arrete = arrete FROM dbo.document_produit WHERE id = @document_id;
    IF @entite IS NULL
        THROW 50622, N'Copie refusée : l''arrêté n''est pas validé pour le client.', 1;
    -- 50616, D1 (15/11/2026) : action 33, garde 50616 de pr_valider_pour_client reprise mot pour mot. Juge sur @par, celui qui clique, par sa connexion, avant toute ecriture (la session SQL d'une
    -- Data function est celle du proprietaire). Un semis ecrit sans cette garde. 61_DEPLOIEMENT/generer_gardes_d1.py.
    IF ISNULL(TRY_CAST(SESSION_CONTEXT(N'semis') AS INT), 0) <> 1
       AND NOT EXISTS (SELECT 1 FROM dbo.role_mission r WHERE r.entite = @entite AND (r.connexion = @par OR r.personne = @par) AND r.role = 'CHEF_MISSION' AND r.du <= CAST(SYSUTCDATETIME() AS DATE) AND (r.au IS NULL OR r.au > CAST(SYSUTCDATETIME() AS DATE)))
        THROW 50616, N'Validation refusée : cette personne n''a pas, sur cette entité, le rôle de chef de mission.', 1;
    IF dbo.fn_valide_pour_client(@entite, @arrete) = 0
        THROW 50622, N'Copie refusée : l''arrêté n''est pas validé pour le client.', 1;
    IF NULLIF(LTRIM(RTRIM(@web_url)), N'') IS NULL OR @web_url NOT LIKE N'https://%'
        THROW 50638, N'Copie refusée : l''adresse de la copie est une adresse https du site du véhicule.', 1;
    INSERT INTO dbo.copie_livrable (document_id, web_url, copie_par) VALUES (@document_id, @web_url, @par);
    SELECT SCOPE_IDENTITY() AS copie_id, N'Copie enregistrée.' AS message;
END;

GO

