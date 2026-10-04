
-- 4. LE DEPOT.
CREATE   PROCEDURE dbo.pr_deposer_classeur
    @entite         VARCHAR (20),
    @arrete         VARCHAR (20),
    @fichier        NVARCHAR (400),
    @contenu_base64 NVARCHAR (MAX),
    @par            NVARCHAR (400),
    @sous_dossier   NVARCHAR (100) = NULL,
    @empreinte      CHAR (64)      = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @url NVARCHAR (800)  = (SELECT valeur FROM dbo.ref_parametre WHERE code = 'DEPOT_CLASSEUR_URL');
    DECLARE @site NVARCHAR (800) = (SELECT valeur FROM dbo.ref_parametre WHERE code = 'SITE_CABINET');
    DECLARE @raccourci NVARCHAR (200) = (SELECT valeur FROM dbo.ref_parametre WHERE code = 'RACCOURCI_SITE_CABINET');
    DECLARE @m NVARCHAR (800);
    SET @sous_dossier = NULLIF(LTRIM(RTRIM(@sous_dossier)), N'');
    SET @empreinte = LOWER(NULLIF(LTRIM(RTRIM(@empreinte)), ''));

    IF NOT EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @entite)
        THROW 50940, N'Entité inconnue.', 1;
    IF NULLIF(LTRIM(RTRIM(@fichier)), N'') IS NULL OR @fichier LIKE N'%/%' OR @fichier LIKE N'%\%'
        THROW 50941, N'Le nom du fichier est obligatoire, et il ne porte aucun séparateur de dossier.', 1;
    IF @sous_dossier LIKE N'%/%' OR @sous_dossier LIKE N'%\%' OR @sous_dossier LIKE N'%..%'
        THROW 50941, N'Le sous-dossier est un nom simple, sans séparateur de dossier.', 1;
    IF NULLIF(@contenu_base64, N'') IS NULL
        THROW 50942, N'Le classeur est vide : rien à déposer.', 1;
    IF NULLIF(LTRIM(RTRIM(@url)), N'') IS NULL OR NULLIF(LTRIM(RTRIM(@site)), N'') IS NULL
        THROW 50943, N'Le dépôt des classeurs n''est pas installé : les paramètres DEPOT_CLASSEUR_URL et SITE_CABINET doivent être renseignés. Voir azure/README.md du dépôt.', 1;
    IF @url NOT LIKE N'https://%' OR @url LIKE N'%]%' OR LEN(@url) > 128
        THROW 50944, N'DEPOT_CLASSEUR_URL doit être une adresse https de 128 caractères au plus, sans crochet fermant.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.database_scoped_credentials WHERE name = @url)
        THROW 50945, N'Aucune DATABASE SCOPED CREDENTIAL ne porte le nom de l''adresse de dépôt. Voir azure/README.md du dépôt.', 1;

    -- L'EMPREINTE DU CONTENU RECU, calculee par la base sur les octets decodes.
    DECLARE @recue CHAR (64) = dbo.fn_empreinte_base64(@contenu_base64);
    IF @sous_dossier = N'Livrables' AND @empreinte IS NULL
        THROW 50627, N'Dépôt refusé : un livrable se dépose avec l''empreinte de son fichier.', 1;
    IF @empreinte IS NOT NULL AND @empreinte <> @recue
    BEGIN
        SET @m = N'Dépôt refusé : l''empreinte transmise ne correspond pas au contenu reçu du fichier ' + @fichier + N'.';
        THROW 50626, @m, 1;
    END;
    IF @sous_dossier = N'Livrables'
       AND EXISTS (SELECT 1 FROM dbo.export_dossier WHERE entite = @entite AND arrete = @arrete AND sous_dossier = N'Livrables'
                   AND fichier = @fichier AND statut = 'FAIT')
        THROW 50609, N'Dépôt refusé : un livrable du même nom est déjà déposé dans le dossier Livrables de cet arrêté ; une version produite ne s''écrase pas.', 1;

    DECLARE @dossier NVARCHAR (400) = N'Dossiers de travail/' + @entite + N'/' + @arrete + ISNULL(N'/' + @sous_dossier, N'');
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
    DECLARE @ecrase BIT = TRY_CAST(JSON_VALUE(@corps, '$.ecrase') AS BIT);
    DECLARE @onelake NVARCHAR (800) = CASE WHEN @statut = 'FAIT' AND NULLIF(@raccourci, N'') IS NOT NULL
                                           THEN @raccourci + N'/' + @dossier + N'/' + @fichier END;
    DECLARE @message NVARCHAR (2000) = CASE
        WHEN @statut <> 'FAIT' THEN LEFT(N'Dépôt refusé, retour ' + CAST(@ret AS NVARCHAR (10)) + N' : '
                  + ISNULL(JSON_VALUE(@corps, '$.message'), ISNULL(@reponse, N'aucune réponse')), 2000)
        WHEN @sous_dossier = N'Livrables' THEN N'Livrable déposé dans le dossier Livrables de l''arrêté. Ouvrez-le par le lien.'
        ELSE N'Dossier déposé dans le site du cabinet. Ouvrez-le par le lien.' END;

    INSERT INTO dbo.export_dossier (entite, arrete, fichier, statut, web_url, chemin_onelake, taille, message, depose_par,
                                    sous_dossier, empreinte_sha256, ecrase)
    VALUES (@entite, @arrete, @fichier, @statut, @web, @onelake,
            TRY_CAST(JSON_VALUE(@corps, '$.taille') AS INT), @message, @par, @sous_dossier, @recue, @ecrase);

    IF @statut <> 'FAIT'
        THROW 50946, @message, 1;
    SELECT @web AS web_url, @onelake AS chemin_onelake, @message AS message, @recue AS empreinte_sha256;
END;

GO

