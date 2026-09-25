
-- --- 4 : la procedure du bouton ----------------------------------------------
CREATE   PROCEDURE dbo.pr_ecran_provisionner_espace
    @entite VARCHAR (20),
    @par    NVARCHAR (400),
    @equipe BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @id INT, @url NVARCHAR (400) = N'https://opci-espaces-fn-acs.azurewebsites.net/api/provisionner_espace';
    INSERT INTO dbo.demande_espace_client (entite, demande_par, equipe_teams)
    VALUES (@entite, @par, @equipe);
    SET @id = SCOPE_IDENTITY();
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @entite)
            THROW 50151, N'Entite inconnue.', 1;
        -- Les proprietaires sont les personnes qui tiennent un role sur l'entite et
        -- dont la connexion est connue : associe signataire et chef de mission.
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
        DECLARE @reponse NVARCHAR (MAX), @ret INT;
        EXEC @ret = sp_invoke_external_rest_endpoint
            @url = @url, @method = 'POST', @payload = @charge, @timeout = 200,
            @credential = [https://opci-espaces-fn-acs.azurewebsites.net/api/provisionner_espace],
            @response = @reponse OUTPUT;
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
    
        -- 13/09/2026 : la relance rend le refus VISIBLE. Sans elle le
        -- service repond 200 et le portail affiche un succes.
        THROW;
    END CATCH;
END;

GO

