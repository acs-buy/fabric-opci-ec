
CREATE   PROCEDURE dbo.pr_deposer_classeur
    @entite         VARCHAR (20),
    @arrete         VARCHAR (20),
    @fichier        NVARCHAR (400),
    @contenu_base64 NVARCHAR (MAX),
    @par            NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @url NVARCHAR (800)  = (SELECT valeur FROM dbo.ref_parametre WHERE code = 'DEPOT_CLASSEUR_URL');
    DECLARE @site NVARCHAR (800) = (SELECT valeur FROM dbo.ref_parametre WHERE code = 'SITE_CABINET');
    DECLARE @raccourci NVARCHAR (200) = (SELECT valeur FROM dbo.ref_parametre WHERE code = 'RACCOURCI_SITE_CABINET');

    IF NOT EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @entite)
        THROW 50940, N'Entité inconnue.', 1;
    IF NULLIF(LTRIM(RTRIM(@fichier)), N'') IS NULL OR @fichier LIKE N'%/%' OR @fichier LIKE N'%\%'
        THROW 50941, N'Le nom du fichier est obligatoire, et il ne porte aucun séparateur de dossier.', 1;
    IF NULLIF(@contenu_base64, N'') IS NULL
        THROW 50942, N'Le classeur est vide : rien à déposer.', 1;
    IF NULLIF(LTRIM(RTRIM(@url)), N'') IS NULL OR NULLIF(LTRIM(RTRIM(@site)), N'') IS NULL
        THROW 50943, N'Le dépôt des classeurs n''est pas installé : les paramètres DEPOT_CLASSEUR_URL et SITE_CABINET doivent être renseignés. Voir azure/README.md du dépôt.', 1;
    -- QUOTENAME rend NULL au-dela de 128 caracteres, et l'appel partirait alors sans credential.
    IF @url NOT LIKE N'https://%' OR @url LIKE N'%]%' OR LEN(@url) > 128
        THROW 50944, N'DEPOT_CLASSEUR_URL doit être une adresse https de 128 caractères au plus, sans crochet fermant.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.database_scoped_credentials WHERE name = @url)
        THROW 50945, N'Aucune DATABASE SCOPED CREDENTIAL ne porte le nom de l''adresse de dépôt. Voir azure/README.md du dépôt.', 1;

    DECLARE @dossier NVARCHAR (400) = N'Dossiers de travail/' + @entite + N'/' + @arrete;
    DECLARE @charge NVARCHAR (MAX) = JSON_MODIFY(JSON_MODIFY(JSON_MODIFY(JSON_MODIFY(N'{}',
        '$.site', @site), '$.dossier', @dossier), '$.fichier', @fichier), '$.contenu_base64', @contenu_base64);
    DECLARE @reponse NVARCHAR (MAX), @ret INT;
    DECLARE @sql NVARCHAR (MAX) = N'
        EXEC @r = sp_invoke_external_rest_endpoint
             @url = @u, @method = ''POST'', @payload = @p, @timeout = 120,
             @credential = ' + QUOTENAME(@url) + N', @response = @rep OUTPUT;';
    EXEC sp_executesql @sql,
         N'@u NVARCHAR(800), @p NVARCHAR(MAX), @rep NVARCHAR(MAX) OUTPUT, @r INT OUTPUT',
         @u = @url, @p = @charge, @rep = @reponse OUTPUT, @r = @ret OUTPUT;

    DECLARE @corps NVARCHAR (MAX) = JSON_QUERY(@reponse, '$.result');
    DECLARE @statut VARCHAR (12) = CASE WHEN JSON_VALUE(@corps, '$.statut') = 'FAIT' THEN 'FAIT' ELSE 'ERREUR' END;
    DECLARE @web NVARCHAR (800) = JSON_VALUE(@corps, '$.web_url');
    DECLARE @onelake NVARCHAR (800) = CASE WHEN @statut = 'FAIT' AND NULLIF(@raccourci, N'') IS NOT NULL
                                           THEN @raccourci + N'/' + @dossier + N'/' + @fichier END;
    DECLARE @message NVARCHAR (2000) = CASE WHEN @statut = 'FAIT'
        THEN N'Dossier déposé dans le site du cabinet. Ouvrez-le par le lien.'
        ELSE LEFT(N'Dépôt refusé, retour ' + CAST(@ret AS NVARCHAR (10)) + N' : '
                  + ISNULL(JSON_VALUE(@corps, '$.message'), ISNULL(@reponse, N'aucune réponse')), 2000) END;

    INSERT INTO dbo.export_dossier (entite, arrete, fichier, statut, web_url, chemin_onelake, taille, message, depose_par)
    VALUES (@entite, @arrete, @fichier, @statut, @web, @onelake,
            TRY_CAST(JSON_VALUE(@corps, '$.taille') AS INT), @message, @par);

    IF @statut <> 'FAIT'
        THROW 50946, @message, 1;
    SELECT @web AS web_url, @onelake AS chemin_onelake, @message AS message;
END;

GO

