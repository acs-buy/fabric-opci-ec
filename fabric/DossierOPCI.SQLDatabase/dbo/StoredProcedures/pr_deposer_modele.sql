
-- 5. LE DEPOT D'UN MODELE DE DOCUMENT. Le modele est un parametrage du cabinet : l'associe d'un dossier le depose.
-- Il va dans « Modeles », a la racine de la bibliotheque du site du cabinet, que le raccourci du coffre couvre ; le
-- nom de fichier est celui que les fonctions de production lisent. Un modele se redepose sous le meme nom.
CREATE   PROCEDURE dbo.pr_deposer_modele
    @fichier        NVARCHAR (400),
    @contenu_base64 NVARCHAR (MAX),
    @par            NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @url NVARCHAR (800)  = (SELECT valeur FROM dbo.ref_parametre WHERE code = 'DEPOT_CLASSEUR_URL');
    DECLARE @site NVARCHAR (800) = (SELECT valeur FROM dbo.ref_parametre WHERE code = 'SITE_CABINET');
    DECLARE @m NVARCHAR (800), @le DATE = CAST(SYSUTCDATETIME() AS DATE);
    IF NULLIF(LTRIM(RTRIM(@fichier)), N'') IS NULL OR @fichier LIKE N'%/%' OR @fichier LIKE N'%\%'
       OR (@fichier NOT LIKE N'%.docx' AND @fichier NOT LIKE N'%.xlsx' AND @fichier NOT LIKE N'%.dotx')
        THROW 50635, N'Dépôt refusé : un modèle est un fichier .docx, .dotx ou .xlsx, nommé sans séparateur de dossier.', 1;
    IF NULLIF(@contenu_base64, N'') IS NULL
        THROW 50942, N'Le classeur est vide : rien à déposer.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.role_mission r WHERE (r.connexion = @par OR r.personne = @par) AND r.role = 'ASSOCIE'
                   AND r.du <= @le AND (r.au IS NULL OR r.au > @le))
        THROW 50636, N'Dépôt refusé : un modèle de document est un paramétrage du cabinet ; il se dépose par un associé.', 1;
    IF NULLIF(LTRIM(RTRIM(@url)), N'') IS NULL OR NULLIF(LTRIM(RTRIM(@site)), N'') IS NULL
        THROW 50943, N'Le dépôt des classeurs n''est pas installé : les paramètres DEPOT_CLASSEUR_URL et SITE_CABINET doivent être renseignés. Voir azure/README.md du dépôt.', 1;
    IF @url NOT LIKE N'https://%' OR @url LIKE N'%]%' OR LEN(@url) > 128
        THROW 50944, N'DEPOT_CLASSEUR_URL doit être une adresse https de 128 caractères au plus, sans crochet fermant.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.database_scoped_credentials WHERE name = @url)
        THROW 50945, N'Aucune DATABASE SCOPED CREDENTIAL ne porte le nom de l''adresse de dépôt. Voir azure/README.md du dépôt.', 1;

    DECLARE @charge NVARCHAR (MAX) = JSON_MODIFY(JSON_MODIFY(JSON_MODIFY(JSON_MODIFY(N'{}',
        '$.site', @site), '$.dossier', N'Modeles'), '$.fichier', @fichier), '$.contenu_base64', @contenu_base64);
    DECLARE @reponse NVARCHAR (MAX), @ret INT;
    DECLARE @sql NVARCHAR (MAX) = N'
        EXEC @r = sp_invoke_external_rest_endpoint
             @url = @u, @method = ''POST'', @payload = @p, @timeout = 120,
             @credential = ' + QUOTENAME(@url) + N', @response = @rep OUTPUT;';
    EXEC sp_executesql @sql,
         N'@u NVARCHAR(800), @p NVARCHAR(MAX), @rep NVARCHAR(MAX) OUTPUT, @r INT OUTPUT',
         @u = @url, @p = @charge, @rep = @reponse OUTPUT, @r = @ret OUTPUT;
    DECLARE @corps NVARCHAR (MAX) = JSON_QUERY(@reponse, '$.result');
    IF ISNULL(JSON_VALUE(@corps, '$.statut'), '') <> 'FAIT'
    BEGIN
        SET @m = LEFT(N'Dépôt refusé, retour ' + CAST(@ret AS NVARCHAR (10)) + N' : '
                      + ISNULL(JSON_VALUE(@corps, '$.message'), ISNULL(@reponse, N'aucune réponse')), 800);
        THROW 50637, @m, 1;
    END;
    SELECT JSON_VALUE(@corps, '$.web_url') AS web_url, dbo.fn_empreinte_base64(@contenu_base64) AS empreinte_sha256,
           TRY_CAST(JSON_VALUE(@corps, '$.taille') AS INT) AS taille,
           CAST(CASE WHEN JSON_VALUE(@corps, '$.ecrase') = 'true' THEN 1 ELSE 0 END AS BIT) AS ecrase,
           N'Modèle ' + @fichier + N' déposé dans le dossier Modeles du site du cabinet.' AS message;
END;

GO

