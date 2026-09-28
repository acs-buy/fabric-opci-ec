-- L'APPEL SE CONSTRUIT, PARCE QUE LA CREDENTIAL SE NOMME PAR L'URL.
-- sp_invoke_external_rest_endpoint apparie la credential a l'adresse PAR SON NOM, et @credential
-- n'accepte pas de variable : une adresse parametree impose donc un appel construit.
-- Defaut introduit puis corrige le 27/09/2026, avant publication : sans credential, la cle de la
-- fonction ne part pas, et l'appel est refuse.
CREATE   PROCEDURE dbo.pr_ecran_provisionner_espace
    @entite VARCHAR (20),
    @par    NVARCHAR (400),
    @equipe BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @id INT, @url NVARCHAR (800) =
        (SELECT valeur FROM dbo.ref_parametre WHERE code = 'ESPACE_CLIENT_URL');
    IF @url IS NULL OR LTRIM(RTRIM(@url)) = N''
        THROW 50152, N'Le provisionnement n''est pas installé : le paramètre ESPACE_CLIENT_URL est vide. Voir azure/README.md du dépôt.', 1;
    IF @url LIKE N'%]%' OR @url NOT LIKE N'https://%'
        THROW 50153, N'ESPACE_CLIENT_URL doit être une adresse https, sans crochet fermant.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.database_scoped_credentials WHERE name = @url)
        THROW 50154, N'Aucune DATABASE SCOPED CREDENTIAL ne porte le nom de cette adresse. Voir azure/README.md du dépôt.', 1;

    INSERT INTO dbo.demande_espace_client (entite, demande_par, equipe_teams)
    VALUES (@entite, @par, @equipe);
    SET @id = SCOPE_IDENTITY();
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @entite)
            THROW 50151, N'Entite inconnue.', 1;
        -- UN SITE PAR VEHICULE, regle du 28/09/2026 : une filiale se range dans le site du vehicule
        -- qui la detient, sous la colonne « Entite legale », et ne recoit pas de site a elle.
        IF EXISTS (SELECT 1 FROM dbo.detention WHERE entite_fille = @entite)
            THROW 50155, N'Une filiale n''a pas de site à elle : ses documents se rangent dans le site de son véhicule, sous la colonne « Entité légale ». Provisionnez le véhicule.', 1;
        DECLARE @proprietaires NVARCHAR (MAX) =
            (SELECT JSON_QUERY('[' + STRING_AGG('"' + STRING_ESCAPE(r.connexion, 'json') + '"', ',') + ']')
             FROM (SELECT DISTINCT connexion FROM dbo.role_mission
                   WHERE entite = @entite AND au IS NULL AND connexion IS NOT NULL
                     AND role IN ('ASSOCIE', 'CHEF_MISSION')) AS r);
        IF @proprietaires IS NULL
            THROW 50151, N'Aucun proprietaire : aucun role de l''entite ne porte de connexion.', 1;
        DECLARE @denomination NVARCHAR (200) = (SELECT denomination FROM dbo.ref_entite WHERE code = @entite);
        DECLARE @charge NVARCHAR (MAX) = JSON_MODIFY(JSON_MODIFY(JSON_MODIFY(JSON_MODIFY('{}',
            '$.entite', @entite), '$.denomination', @denomination),
            '$.proprietaires', JSON_QUERY(@proprietaires)), '$.equipe', CAST(@equipe AS BIT));
        -- UN SITE POUR LE VEHICULE ET SES FILIALES, regle du 28/09/2026. La fonction
        -- en fait les choix de la colonne « Entite legale » de chaque bibliotheque.
        DECLARE @entites NVARCHAR (MAX) =
            (SELECT JSON_QUERY('[' + STRING_AGG('"' + STRING_ESCAPE(x.code, 'json') + '"', ',') + ']')
             FROM (SELECT @entite AS code UNION SELECT dt.entite_fille FROM dbo.detention dt
                   WHERE dt.entite_mere = @entite) AS x);
        SET @charge = JSON_MODIFY(@charge, '$.entites', JSON_QUERY(@entites));
        DECLARE @reponse NVARCHAR (MAX), @ret INT;
        DECLARE @sql NVARCHAR (MAX) = N'
            EXEC @r = sp_invoke_external_rest_endpoint
                 @url = @u, @method = ''POST'', @payload = @p, @timeout = 200,
                 @credential = ' + QUOTENAME(@url) + N', @response = @rep OUTPUT;';
        EXEC sp_executesql @sql,
             N'@u NVARCHAR(800), @p NVARCHAR(MAX), @rep NVARCHAR(MAX) OUTPUT, @r INT OUTPUT',
             @u = @url, @p = @charge, @rep = @reponse OUTPUT, @r = @ret OUTPUT;
        DECLARE @corps NVARCHAR (MAX) = JSON_QUERY(@reponse, '$.result');
        DECLARE @statut VARCHAR (12) = ISNULL(JSON_VALUE(@corps, '$.statut'), 'ERREUR');
        UPDATE dbo.demande_espace_client
           SET statut = CASE WHEN @statut IN ('FAIT', 'PARTIEL', 'ERREUR') THEN @statut ELSE 'ERREUR' END,
               groupe_id = JSON_VALUE(@corps, '$.groupe_id'),
               site_url = JSON_VALUE(@corps, '$.site_url'),
               reponse = @reponse, repondu_le = SYSUTCDATETIME(),
               message_ecran = CASE WHEN @statut = 'FAIT' THEN NULL
                                    ELSE LEFT(N'Retour ' + CAST(@ret AS NVARCHAR (10)) + N' : '
                                              + ISNULL(JSON_VALUE(@corps, '$.message'), ISNULL(@reponse, N'aucune reponse')), 2000) END,
               message_ecran_le = CASE WHEN @statut = 'FAIT' THEN NULL ELSE SYSUTCDATETIME() END,
               message_ecran_pour = CASE WHEN @statut = 'FAIT' THEN NULL ELSE LEFT(@par, 200) END
         WHERE id = @id;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        UPDATE dbo.demande_espace_client
           SET statut = 'ERREUR', repondu_le = SYSUTCDATETIME(),
               message_ecran = LEFT(ERROR_MESSAGE(), 2000),
               message_ecran_le = SYSUTCDATETIME(), message_ecran_pour = LEFT(@par, 200)
         WHERE id = @id;
        THROW;
    END CATCH;
    SELECT d.statut, d.site_url, d.groupe_id, d.message_ecran
      FROM dbo.demande_espace_client d WHERE d.id = @id;
END;

GO

