-- ===================================================================== LE DEPOT D'UN CLASSEUR DU CABINET
-- Depose au dossier Referentiels du site du cabinet, par la route deposer_classeur (voie de
-- pr_deposer_classeur), le classeur d'un referentiel (REFERENTIEL) ou des niveaux de programme (NIVEAUX), puis inscrit
-- le depot dans classeur_cabinet. La route cree le dossier absent ; chemin_onelake se lit tel quel par le raccourci.
CREATE PROCEDURE dbo.pr_deposer_classeur_referentiel
    @genre          NVARCHAR (40)   = NULL,
    @referentiel    NVARCHAR (400)  = NULL,
    @fichier        NVARCHAR (4000) = NULL,
    @contenu_base64 NVARCHAR (MAX)  = NULL,
    @par            NVARCHAR (400)  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    -- @@TRANCOUNT lu seul, avant toute lecture de table : sous IMPLICIT_TRANSACTIONS (connexion sans autocommit d'une
    -- Data function), la 1re lecture ouvrirait la transaction de l'appelant avant la mesure
    DECLARE @tc INT = @@TRANCOUNT;
    DECLARE @journal_avant INT = ISNULL((SELECT MAX(id) FROM dbo.journal_refus), 0),
            @proc VARCHAR (60) = 'pr_deposer_classeur_referentiel', @e_num INT, @e_msg NVARCHAR (2048), @e_fr NVARCHAR (2000),
            @e_journal NVARCHAR (2000), @m NVARCHAR (2000), @message NVARCHAR (2000);
    -- le vide : les 29 caracteres de str.isspace(), compares au point de code
    DECLARE @blancs NVARCHAR (29) = NCHAR(9) + NCHAR(10) + NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(28) + NCHAR(29) + NCHAR(30) + NCHAR(31) + NCHAR(32)
        + NCHAR(133) + NCHAR(160) + NCHAR(5760) + NCHAR(8192) + NCHAR(8193) + NCHAR(8194) + NCHAR(8195) + NCHAR(8196) + NCHAR(8197) + NCHAR(8198)
        + NCHAR(8199) + NCHAR(8200) + NCHAR(8201) + NCHAR(8202) + NCHAR(8232) + NCHAR(8233) + NCHAR(8239) + NCHAR(8287) + NCHAR(12288);
    DECLARE @g NVARCHAR (40), @t VARCHAR (120), @lib NVARCHAR (160), @mode VARCHAR (5), @actions TINYINT, @propre NVARCHAR (60),
            @designation VARCHAR (128), @url NVARCHAR (800), @site NVARCHAR (800), @raccourci NVARCHAR (200),
            @recue CHAR (64), @dossier NVARCHAR (400) = N'Référentiels', @charge NVARCHAR (MAX), @reponse NVARCHAR (MAX),
            @ret INT, @sql NVARCHAR (MAX), @corps NVARCHAR (MAX), @statut NVARCHAR (40), @web NVARCHAR (800),
            @onelake NVARCHAR (800), @detail NVARCHAR (4000), @code_retour NVARCHAR (12), @p INT, @id INT,
            @detail_route NVARCHAR (4000), @http NVARCHAR (200);
    -- la cle detail_route : remise a vide a chaque appel, une connexion de fonction pouvant resservir
    EXEC sp_set_session_context N'detail_route', NULL;
    BEGIN TRY
        -- 1. l'auteur, puis par pose avant la 1re ecriture
        IF ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM @par COLLATE Latin1_General_100_BIN2)), 0) = 0
            EXEC dbo.pr_e5_refuser 50900, N'Action refusée : l’auteur de l’action n’est pas transmis ; l’écran le transmet avec l’adresse de connexion de la personne qui clique.';
        SET @par = LTRIM(RTRIM(@par));
        EXEC sp_set_session_context N'par', @par;
        -- 2. le genre et le referentiel
        IF ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM @genre COLLATE Latin1_General_100_BIN2)), 0) = 0
            EXEC dbo.pr_e5_refuser 50901, N'Dépôt refusé : le genre du classeur manque ; « REFERENTIEL » pour le classeur d’un référentiel, « NIVEAUX » pour le classeur des niveaux de programme.';
        SET @g = UPPER(LTRIM(RTRIM(@genre)));
        IF @g NOT IN (N'REFERENTIEL', N'NIVEAUX')
        BEGIN
            SET @m = N'Dépôt refusé : « ' + @g + N' » n’est pas un genre de classeur du cabinet ; « REFERENTIEL » pour le classeur d’un référentiel, « NIVEAUX » pour le classeur des niveaux de programme.';
            EXEC dbo.pr_e5_refuser 50901, @m;
        END;
        IF @g = N'REFERENTIEL'
        BEGIN
            IF ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM @referentiel COLLATE Latin1_General_100_BIN2)), 0) = 0
                EXEC dbo.pr_e5_refuser 50831, N'Choisissez le référentiel dans la liste « Référentiel ».';
            SET @referentiel = LEFT(LTRIM(RTRIM(@referentiel)), 200);
            -- registre, referentiel du cabinet, table presente (50831) ; un referentiel fixe par un texte s'exporte aussi
            EXEC dbo.pr_e5_lire_referentiel @referentiel, @t OUTPUT, @lib OUTPUT, @mode OUTPUT, @actions OUTPUT, @propre OUTPUT, @designation OUTPUT;
        END
        ELSE IF NOT (ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM @referentiel COLLATE Latin1_General_100_BIN2)), 0) = 0)
        BEGIN
            SET @m = N'Dépôt refusé : le classeur des niveaux de programme ne porte aucun référentiel, et « ' + LEFT(LTRIM(RTRIM(@referentiel)), 200) + N' » est transmis.';
            EXEC dbo.pr_e5_refuser 50901, @m;
        END;
        -- 51324 : la garde du referentiel, jugee sur @par ; refus par pr_e5_refuser, dans le TRY. Juge sur @par, celui qui clique, par sa connexion, avant toute ecriture (la session SQL d'une
        -- Data function est celle du proprietaire). Un semis ecrit sans cette garde.
        IF ISNULL(TRY_CAST(SESSION_CONTEXT(N'semis') AS INT), 0) <> 1 AND dbo.fn_peut_ecrire_referentiel(CASE WHEN @g = N'NIVEAUX' THEN 'ref_question' ELSE @t END, @par) = 0
        BEGIN
            SET @m = N'Dépôt refusé sur «' + NCHAR(8239) + dbo.fn_e5_libelle_referentiel(CASE WHEN @g = N'NIVEAUX' THEN 'ref_question' ELSE @t END) + NCHAR(8239) + N'» : aucun droit de modification.';
            EXEC dbo.pr_e5_refuser 51324, @m;
        END;
        -- 3. le nom du classeur : un nom de fichier du site du cabinet, en .xlsx
        IF ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM @fichier COLLATE Latin1_General_100_BIN2)), 0) = 0
            EXEC dbo.pr_e5_refuser 50902, N'Dépôt refusé : le nom du classeur est vide.';
        SET @fichier = LTRIM(RTRIM(@fichier));
        IF LEN(@fichier) > 400
        BEGIN
            SET @m = N'Dépôt refusé : le nom du classeur porte ' + CAST(LEN(@fichier) AS NVARCHAR (12)) + N' caractères, pour 400 au plus.';
            EXEC dbo.pr_e5_refuser 50902, @m;
        END;
        IF @fichier LIKE N'%[/\:*?"<>|]%' OR @fichier LIKE N'%..%'
           OR @fichier COLLATE Latin1_General_100_BIN2 LIKE N'%[' + NCHAR(1) + N'-' + NCHAR(31) + N']%'
        BEGIN
            SET @m = N'Dépôt refusé : le nom du classeur « ' + @fichier + N' » porte un caractère qu’un nom de fichier du site du cabinet n’admet pas : / \ : * ? " < > |, un caractère de contrôle ou « .. ».';
            EXEC dbo.pr_e5_refuser 50902, @m;
        END;
        IF @fichier NOT LIKE N'%_.xlsx'
        BEGIN
            SET @m = N'Dépôt refusé : un classeur du cabinet se dépose en .xlsx, et « ' + @fichier + N' » n’en est pas un.';
            EXEC dbo.pr_e5_refuser 50902, @m;
        END;
        -- 4. le contenu : un classeur Excel (archive zip) encode en base64, que la base decode pour son empreinte
        IF ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM @contenu_base64 COLLATE Latin1_General_100_BIN2)), 0) = 0
            EXEC dbo.pr_e5_refuser 50903, N'Dépôt refusé : le classeur est vide, rien à déposer.';
        IF @contenu_base64 COLLATE Latin1_General_100_BIN2 LIKE N'%[^A-Za-z0-9+/=]%' OR LEN(@contenu_base64) % 4 <> 0
           OR LEFT(@contenu_base64, 4) COLLATE Latin1_General_100_BIN2 <> N'UEsD'
            EXEC dbo.pr_e5_refuser 50903, N'Dépôt refusé : le contenu reçu n’est pas un classeur Excel encodé en base64.';
        -- 5. l'installation du depot, celle de pr_deposer_classeur, et le raccourci qui relit le classeur
        SELECT @url = (SELECT p.valeur FROM dbo.ref_parametre p WHERE p.code = 'DEPOT_CLASSEUR_URL'),
               @site = (SELECT p.valeur FROM dbo.ref_parametre p WHERE p.code = 'SITE_CABINET'),
               @raccourci = (SELECT p.valeur FROM dbo.ref_parametre p WHERE p.code = 'RACCOURCI_SITE_CABINET');
        IF NULLIF(LTRIM(RTRIM(@url)), N'') IS NULL OR NULLIF(LTRIM(RTRIM(@site)), N'') IS NULL
            EXEC dbo.pr_e5_refuser 50904, N'Dépôt refusé : le dépôt des classeurs n’est pas installé ; les paramètres DEPOT_CLASSEUR_URL et SITE_CABINET doivent être renseignés (azure/README.md du dépôt).';
        IF @url NOT LIKE N'https://%' OR @url LIKE N'%]%' OR LEN(@url) > 128
            EXEC dbo.pr_e5_refuser 50904, N'Dépôt refusé : DEPOT_CLASSEUR_URL doit être une adresse https de 128 caractères au plus, sans crochet fermant.';
        IF NOT EXISTS (SELECT 1 FROM sys.database_scoped_credentials WHERE name = @url)
            EXEC dbo.pr_e5_refuser 50904, N'Dépôt refusé : aucune DATABASE SCOPED CREDENTIAL ne porte le nom de l’adresse de dépôt (azure/README.md du dépôt).';
        IF NULLIF(LTRIM(RTRIM(@raccourci)), N'') IS NULL
            EXEC dbo.pr_e5_refuser 50904, N'Dépôt refusé : le raccourci du site du cabinet n’est pas installé (paramètre RACCOURCI_SITE_CABINET) ; sans lui, le classeur déposé ne se relit pas.';
        -- 6. l'empreinte des octets recus, calculee par la base sur le base64 decode avant l'appel de la route ; c'est
        --    elle que classeur_cabinet.empreinte_sha256 garde. SharePoint reecrit l'enveloppe d'un fichier Office
        --    depose : la copie stockee, relue par le raccourci, peut avoir une autre empreinte, et aucune procedure
        --    ne compare les deux.
        SET @recue = dbo.fn_empreinte_base64(@contenu_base64);
        SET @charge = JSON_MODIFY(JSON_MODIFY(JSON_MODIFY(JSON_MODIFY(N'{}', '$.site', @site), '$.dossier', @dossier),
                                  '$.fichier', @fichier), '$.contenu_base64', @contenu_base64);
        SET @sql = N'EXEC @r = sp_invoke_external_rest_endpoint @url = @u, @method = ''POST'', @payload = @p, @timeout = 120, @credential = '
                 + QUOTENAME(@url) + N', @response = @rep OUTPUT;';
        BEGIN TRY
            EXEC sp_executesql @sql, N'@u NVARCHAR (800), @p NVARCHAR (MAX), @rep NVARCHAR (MAX) OUTPUT, @r INT OUTPUT',
                 @u = @url, @p = @charge, @rep = @reponse OUTPUT, @r = @ret OUTPUT;
        END TRY
        BEGIN CATCH
            -- le detail de l'erreur de l'appel (numero et texte, qui peut etre anglais), pour le seul journal des refus
            SET @detail_route = LEFT(N'Dépôt refusé, route de dépôt sans réponse, ' + @proc + N', classeur « ' + @fichier + N' » : erreur '
                                     + CAST(ERROR_NUMBER() AS NVARCHAR (12)) + N' : ' + ISNULL(ERROR_MESSAGE(), N''), 4000);
            SET @m = N'Dépôt refusé : la route de dépôt du site du cabinet n’a pas répondu (erreur ' + CAST(ERROR_NUMBER() AS NVARCHAR (12))
                   + N') ; le classeur « ' + @fichier + N' » n’est pas déposé.';
            EXEC dbo.pr_e5_refuser 50905, @m;
        END CATCH;
        IF ISJSON(@reponse) = 1
            SET @corps = JSON_QUERY(@reponse, '$.result');
        IF ISJSON(@corps) = 1
            SELECT @statut = JSON_VALUE(@corps, '$.statut'), @web = JSON_VALUE(@corps, '$.web_url'), @detail = JSON_VALUE(@corps, '$.message');
        IF ISNULL(@statut, N'') <> N'FAIT'
        BEGIN
            -- le code a 3 chiffres que la route cite entre parentheses (« depot refuse (409) : ... »), sans son texte
            SET @p = PATINDEX(N'%([0-9][0-9][0-9])%', ISNULL(@detail, N''));
            SET @code_retour = CASE WHEN @p > 0 THEN SUBSTRING(@detail, @p + 1, 3) WHEN ISNULL(@ret, 0) <> 0 THEN CAST(@ret AS NVARCHAR (12)) END;
            -- le detail de la route : son code de retour, le statut HTTP de l'appel et son texte (Graph compris, qui peut etre
            -- anglais), pour le seul journal des refus ; l'ecran garde le texte francais
            SET @http = CASE WHEN ISJSON(@reponse) = 1
                             THEN LEFT(JSON_VALUE(@reponse, '$.response.status.http.code') + ISNULL(N' ' + JSON_VALUE(@reponse, '$.response.status.http.description'), N''), 200) END;
            SET @detail_route = LEFT(N'Dépôt refusé par la route de dépôt du site du cabinet, ' + @proc + N', classeur « ' + @fichier + N' » : retour '
                                     + ISNULL(CAST(@ret AS NVARCHAR (12)), N'inconnu') + ISNULL(N', HTTP ' + @http, N'') + N' : '
                                     + COALESCE(@detail, CASE WHEN @statut IS NOT NULL THEN N'statut ' + @statut END, LEFT(@reponse, 3000), N'aucune réponse'), 4000);
            SET @m = N'Dépôt refusé : le site du cabinet n’a pas reçu le classeur « ' + @fichier + N' »'
                   + ISNULL(N' (retour ' + @code_retour + N')', N'') + N' ; le détail est au journal de la route de dépôt.';
            EXEC dbo.pr_e5_refuser 50905, @m;
        END;
        SET @onelake = LTRIM(RTRIM(@raccourci)) + N'/' + @dossier + N'/' + @fichier;
        -- 7. l'inscription du depot fait, et le message
        BEGIN TRANSACTION;
        INSERT INTO dbo.classeur_cabinet (genre, referentiel, fichier, web_url, chemin_onelake, empreinte_sha256, depose_par)
        VALUES (CAST(@g AS VARCHAR (12)), @t, @fichier, @web, @onelake, @recue, @par);
        SET @id = SCOPE_IDENTITY();
        SET @message = CASE WHEN @g = N'REFERENTIEL'
                            THEN N'Classeur du référentiel « ' + @lib + N' » déposé au dossier Référentiels du site du cabinet : « ' + @fichier + N' ».'
                            ELSE N'Classeur des niveaux de programme déposé au dossier Référentiels du site du cabinet : « ' + @fichier + N' ».' END;
        EXEC dbo.pr_poser_message_ecran @pour = @par, @message = @message, @genre = 'SUCCES', @entite = '-', @procedure_nom = @proc;
        COMMIT TRANSACTION;
        EXEC sp_set_session_context N'par', NULL;
        SELECT CAST('-' AS VARCHAR (20)) AS entite, @id AS classeur_id, @web AS web_url, @onelake AS chemin_onelake,
               @recue AS empreinte_sha256, @message AS message;
    END TRY
    BEGIN CATCH
        SELECT @e_num = ERROR_NUMBER(), @e_msg = ERROR_MESSAGE();
        IF @tc = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        BEGIN TRY EXEC sp_set_session_context N'par', NULL; END TRY BEGIN CATCH END CATCH;
        -- une contrainte de la table se dit en francais par le libelle de sa colonne, jamais par son nom
        SET @e_fr = dbo.fn_e5_traduire_erreur(@e_num, @e_msg);
        IF @e_fr IS NULL AND @e_num = 515
            SET @e_fr = N'Dépôt refusé : une colonne obligatoire de l’inscription du classeur est vide ; le classeur est déposé au site du cabinet, sans inscription.';
        SET @e_journal = ISNULL(@e_fr, @e_msg);
        -- 50905 : le detail de la route au journal des refus, a la place du texte de l'ecran, qui reste en francais (forme
        -- des fonctions, detail technique au seul journal) ; memes conditions que pr_e5_conclure_refus ; ne refuse jamais
        IF @e_num = 50905 AND @detail_route IS NOT NULL
        BEGIN
            IF @tc = 0 AND @@TRANCOUNT = 0 AND NULLIF(LTRIM(RTRIM(@par)), N'') IS NOT NULL
            BEGIN
                BEGIN TRY
                    INSERT INTO dbo.journal_refus (procedure_nom, entite, message, refuse_pour, refuse_le)
                    VALUES (@proc, NULL, LEFT(@detail_route, 2000), LEFT(LTRIM(RTRIM(@par)), 200), SYSUTCDATETIME());
                    EXEC dbo.pr_poser_message_ecran @pour = @par, @message = @e_msg, @genre = 'REFUS', @entite = '-', @procedure_nom = @proc;
                END TRY
                BEGIN CATCH
                END CATCH;
            END;
        END
        ELSE
            EXEC dbo.pr_e5_conclure_refus @tc, @journal_avant, @proc, @par, '-', @e_journal;
        -- 50905 : sous la transaction d'une fonction, la ligne du journal part avec son rollback ; le
        -- detail passe aussi par la cle detail_route du contexte de session, qui survit au rollback,
        -- relue par la fonction apres son rollback, passee en detail de son journal, puis remise a vide.
        -- Posee sur tout 50905 : @tc vaut 0 sur une connexion de fonction sans autocommit, la transaction implicite ne
        -- s'ouvrant qu'a la 1re lecture de table ; sans effet dans un appel direct, l'appel
        -- suivant la remettant a vide
        IF @e_num = 50905 AND @detail_route IS NOT NULL
            BEGIN TRY EXEC sp_set_session_context N'detail_route', @detail_route; END TRY BEGIN CATCH END CATCH;
        IF @e_fr IS NOT NULL EXEC dbo.pr_e5_refuser 50928, @e_fr;
        THROW;
    END CATCH;
END;

GO

