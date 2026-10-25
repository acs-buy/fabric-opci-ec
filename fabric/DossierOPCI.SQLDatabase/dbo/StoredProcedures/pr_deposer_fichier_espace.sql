
-- pr_deposer_fichier_espace : 1 refus
-- DEPOSER UN FICHIER DANS L'ESPACE SHAREPOINT D'UN VEHICULE, classe par entite legale.
-- Regle du 28/09/2026 : tout fichier se depose dans SharePoint, et le coffre ne le
-- voit que par un raccourci. Decision du meme jour : UN site pour un vehicule et ses filiales, les
-- pieces s'y classant par la colonne « Entite legale ».
--
-- LE SITE SE TROUVE, IL NE SE DONNE PAS. C'est celui du vehicule qui detient l'entite, et celui de
-- l'entite seulement si elle n'est detenue par aucun vehicule pourvu d'un espace : une filiale qui
-- garderait un site d'avant la regle du 28/09 ne le recoit plus. Sans espace, le depot est refuse.
CREATE   PROCEDURE dbo.pr_deposer_fichier_espace
    @entite         VARCHAR (20),
    @bibliotheque   NVARCHAR (200),
    @dossier        NVARCHAR (400),
    @fichier        NVARCHAR (400),
    @contenu_base64 NVARCHAR (MAX),
    @par            NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    -- 327 debut (24/10/2026) : un champ vide se refuse en francais avant toute ecriture, au texte du champ dans le
    -- plan de l'etude des fonctions (decision A du candidat). Genere par 61_DEPLOIEMENT/generer_327_refus_champs_vides.py.
    -- Place : le dossier vide reste admis : depot a la racine.
    -- le vide : les 29 caracteres de str.isspace(), compares au point de code
    DECLARE @r327_blancs NVARCHAR (29) = NCHAR(9) + NCHAR(10) + NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(28) + NCHAR(29) + NCHAR(30) + NCHAR(31) + NCHAR(32)
        + NCHAR(133) + NCHAR(160) + NCHAR(5760) + NCHAR(8192) + NCHAR(8193) + NCHAR(8194) + NCHAR(8195) + NCHAR(8196) + NCHAR(8197) + NCHAR(8198)
        + NCHAR(8199) + NCHAR(8200) + NCHAR(8201) + NCHAR(8202) + NCHAR(8232) + NCHAR(8233) + NCHAR(8239) + NCHAR(8287) + NCHAR(12288);
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @entite COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51201, N'Choisissez le véhicule dans le sélecteur Véhicule.', 1;
    -- 327 fin
    DECLARE @url NVARCHAR (800) = (SELECT valeur FROM dbo.ref_parametre WHERE code = 'DEPOT_CLASSEUR_URL');
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @entite)
        THROW 50950, N'Entité inconnue.', 1;
    IF @bibliotheque NOT IN (N'Dépôt du client', N'Dossier permanent', N'Dossier annuel', N'Livrables')
        THROW 50951, N'La bibliothèque est l''une des 4 de l''espace : Dépôt du client, Dossier permanent, Dossier annuel, Livrables.', 1;
    IF NULLIF(LTRIM(RTRIM(@fichier)), N'') IS NULL OR @fichier LIKE N'%/%' OR @fichier LIKE N'%\%'
        THROW 50952, N'Le nom du fichier est obligatoire, et il ne porte aucun séparateur de dossier.', 1;
    IF NULLIF(@contenu_base64, N'') IS NULL
        THROW 50953, N'Le fichier est vide : rien à déposer.', 1;
    IF NULLIF(LTRIM(RTRIM(@url)), N'') IS NULL OR @url NOT LIKE N'https://%' OR @url LIKE N'%]%' OR LEN(@url) > 128
        THROW 50954, N'Le dépôt n''est pas installé : DEPOT_CLASSEUR_URL doit être une adresse https de 128 caractères au plus. Voir azure/README.md du dépôt.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.database_scoped_credentials WHERE name = @url)
        THROW 50955, N'Aucune DATABASE SCOPED CREDENTIAL ne porte le nom de l''adresse de dépôt. Voir azure/README.md du dépôt.', 1;

    DECLARE @site_url NVARCHAR (800) =
        COALESCE((SELECT TOP 1 d.site_url FROM dbo.demande_espace_client d
                  JOIN dbo.detention dt ON dt.entite_mere = d.entite
                  WHERE dt.entite_fille = @entite AND d.statut = 'FAIT' AND d.site_url IS NOT NULL
                  ORDER BY d.id DESC),
                 (SELECT TOP 1 site_url FROM dbo.demande_espace_client
                  WHERE entite = @entite AND statut = 'FAIT' AND site_url IS NOT NULL ORDER BY id DESC));
    IF @site_url IS NULL
        THROW 50956, N'Ni cette entité ni le véhicule qui la détient n''ont d''espace SharePoint : provisionnez d''abord celui du véhicule.', 1;
    -- https://<hote>/sites/<nom>  devient  <hote>:/sites/<nom>, la forme que Graph attend.
    DECLARE @sans NVARCHAR (800) = SUBSTRING(@site_url, LEN(N'https://') + 1, 800);
    DECLARE @site NVARCHAR (800) = STUFF(@sans, CHARINDEX(N'/', @sans), 0, N':');

    DECLARE @charge NVARCHAR (MAX) = JSON_MODIFY(JSON_MODIFY(JSON_MODIFY(JSON_MODIFY(JSON_MODIFY(JSON_MODIFY(N'{}',
        '$.site', @site), '$.bibliotheque', @bibliotheque), '$.dossier', ISNULL(@dossier, N'')),
        '$.fichier', @fichier), '$.contenu_base64', @contenu_base64), '$.entite_legale', @entite);
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
        DECLARE @m NVARCHAR (2000) = LEFT(N'Dépôt refusé, retour ' + CAST(@ret AS NVARCHAR (10)) + N' : '
              + ISNULL(JSON_VALUE(@corps, '$.message'), ISNULL(@reponse, N'aucune réponse')), 2000);
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50957, @m, 1; END
    END
    SELECT JSON_VALUE(@corps, '$.web_url') AS web_url,
           JSON_VALUE(@corps, '$.entite_legale') AS entite_legale,
           N'Fichier déposé dans l''espace SharePoint.' AS message;
END;

GO

