-- ===================================================================== LE RATTACHEMENT DU FICHIER D'UN GABARIT
-- Inscrit sur modele_feuille le fichier depose au dossier Modeles du site du cabinet, lu par la fonction au
-- raccourci du coffre (fec/Modeles/<fichier>) avec son empreinte : nom_fichier, chemin_coffre, empreinte_sha256. Associe
-- seul. @referentiel, facultatif : le referentiel choisi a l'ecran, refuse s'il ne porte pas de fichier.
CREATE PROCEDURE dbo.pr_ecran_rattacher_gabarit
    @modele        NVARCHAR (400)  = NULL,
    @fichier       NVARCHAR (4000) = NULL,
    @chemin_coffre NVARCHAR (4000) = NULL,
    @empreinte     NVARCHAR (400)  = NULL,
    @web_url       NVARCHAR (4000) = NULL,
    @par           NVARCHAR (400)  = NULL,
    @referentiel   NVARCHAR (400)  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    -- @@TRANCOUNT lu seul, avant toute lecture de table : sous IMPLICIT_TRANSACTIONS (connexion sans autocommit d'une
    -- Data function), la 1re lecture ouvrirait la transaction de l'appelant avant la mesure
    DECLARE @tc INT = @@TRANCOUNT;
    DECLARE @journal_avant INT = ISNULL((SELECT MAX(id) FROM dbo.journal_refus), 0),
            @proc VARCHAR (60) = 'pr_ecran_rattacher_gabarit', @e_num INT, @e_msg NVARCHAR (2048), @e_fr NVARCHAR (2000),
            @e_journal NVARCHAR (2000), @m NVARCHAR (2000), @message NVARCHAR (2000);
    -- le vide : les 29 caracteres de str.isspace(), compares au point de code
    DECLARE @blancs NVARCHAR (29) = NCHAR(9) + NCHAR(10) + NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(28) + NCHAR(29) + NCHAR(30) + NCHAR(31) + NCHAR(32)
        + NCHAR(133) + NCHAR(160) + NCHAR(5760) + NCHAR(8192) + NCHAR(8193) + NCHAR(8194) + NCHAR(8195) + NCHAR(8196) + NCHAR(8197) + NCHAR(8198)
        + NCHAR(8199) + NCHAR(8200) + NCHAR(8201) + NCHAR(8202) + NCHAR(8232) + NCHAR(8233) + NCHAR(8239) + NCHAR(8287) + NCHAR(12288);
    DECLARE @t VARCHAR (120), @lib NVARCHAR (160), @mode VARCHAR (5), @actions TINYINT, @propre NVARCHAR (60),
            @designation VARCHAR (128), @code VARCHAR (20), @libelle_m NVARCHAR (400), @nom_avant NVARCHAR (400),
            @chemin_avant NVARCHAR (400), @emp_avant CHAR (64), @raccourci NVARCHAR (200), @attendu NVARCHAR (4000),
            @chemin NVARCHAR (400);
    BEGIN TRY
        -- 1. l'auteur, puis par pose avant la 1re ecriture
        IF ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM @par COLLATE Latin1_General_100_BIN2)), 0) = 0
            EXEC dbo.pr_e5_refuser 50900, N'Action refusée : l’auteur de l’action n’est pas transmis ; l’écran le transmet avec l’adresse de connexion de la personne qui clique.';
        SET @par = LTRIM(RTRIM(@par));
        EXEC sp_set_session_context N'par', @par;
        -- 2. les raisons de [Blocage rattacher le fichier], dans l'ordre de la mesure : le referentiel choisi qui ne porte
        --    pas de fichier (adresse_fichiers vide de v_ecran_referentiel_choix), puis le droit
        IF NOT (ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM @referentiel COLLATE Latin1_General_100_BIN2)), 0) = 0)
        BEGIN
            SET @referentiel = LEFT(LTRIM(RTRIM(@referentiel)), 200);
            EXEC dbo.pr_e5_lire_referentiel @referentiel, @t OUTPUT, @lib OUTPUT, @mode OUTPUT, @actions OUTPUT, @propre OUTPUT, @designation OUTPUT;
            IF NOT EXISTS (SELECT 1 FROM dbo.v_ecran_referentiel_choix ch WHERE ch.table_nom = @t AND NULLIF(LTRIM(RTRIM(ch.adresse_fichiers)), N'') IS NOT NULL)
            BEGIN
                SET @m = N'Rattachement refusé sur « ' + @lib + N' » : le référentiel choisi ne porte pas de fichier.';
                EXEC dbo.pr_e5_refuser 50923, @m;
            END;
        END;
        IF dbo.fn_peut_ecrire_referentiel('modele_feuille', @par) = 0
        BEGIN
            SET @m = N'Rattachement refusé sur « ' + dbo.fn_e5_libelle_referentiel('modele_feuille') + N' » : aucun droit de modification.';
            EXEC dbo.pr_e5_refuser 50908, @m;
        END;
        -- 3. le modele : son code (la ligne choisie) ou son libelle
        IF ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM @modele COLLATE Latin1_General_100_BIN2)), 0) = 0
            EXEC dbo.pr_e5_refuser 50924, N'Choisissez le modèle de feuille dans la liste « Ligne ».';
        SET @modele = LTRIM(RTRIM(@modele));
        SELECT TOP (1) @code = mf.code, @libelle_m = mf.libelle, @nom_avant = mf.nom_fichier, @chemin_avant = mf.chemin_coffre,
                       @emp_avant = mf.empreinte_sha256
        FROM dbo.modele_feuille mf WHERE mf.code = @modele OR mf.libelle = @modele
        ORDER BY CASE WHEN mf.code = @modele THEN 0 ELSE 1 END;
        IF @code IS NULL
        BEGIN
            SET @m = N'Rattachement refusé : « ' + LEFT(@modele, 200) + N' » n’est pas un modèle de feuille de travail.';
            EXEC dbo.pr_e5_refuser 50924, @m;
        END;
        -- 4. le fichier : un nom simple, en .docx, .dotx ou .xlsx
        IF ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM @fichier COLLATE Latin1_General_100_BIN2)), 0) = 0
            EXEC dbo.pr_e5_refuser 50925, N'Le champ « Nom du fichier déposé » est vide : saisissez le nom du fichier déposé au dossier Modeles du site du cabinet.';
        SET @fichier = LTRIM(RTRIM(@fichier));
        IF LEN(@fichier) > 400
        BEGIN
            SET @m = N'« Nom du fichier déposé » : ' + CAST(LEN(@fichier) AS NVARCHAR (12)) + N' caractères, pour 400 au plus.';
            EXEC dbo.pr_e5_refuser 50925, @m;
        END;
        IF @fichier LIKE N'%[/\:*?"<>|]%' OR @fichier LIKE N'%..%'
           OR @fichier COLLATE Latin1_General_100_BIN2 LIKE N'%[' + NCHAR(1) + N'-' + NCHAR(31) + N']%'
        BEGIN
            SET @m = N'« Nom du fichier déposé » : « ' + @fichier + N' » se saisit sans dossier, et sans les caractères / \ : * ? " < > | ni « .. ».';
            EXEC dbo.pr_e5_refuser 50925, @m;
        END;
        IF @fichier NOT LIKE N'%_.docx' AND @fichier NOT LIKE N'%_.dotx' AND @fichier NOT LIKE N'%_.xlsx'
        BEGIN
            SET @m = N'Rattachement refusé : un gabarit est un fichier .docx, .dotx ou .xlsx, et « ' + @fichier + N' » n’en est pas un.';
            EXEC dbo.pr_e5_refuser 50925, @m;
        END;
        -- 5. l'emplacement : le dossier Modeles par le raccourci du site du cabinet, celui que la fonction lit
        SET @raccourci = NULLIF(LTRIM(RTRIM((SELECT p.valeur FROM dbo.ref_parametre p WHERE p.code = 'RACCOURCI_SITE_CABINET'))), N'');
        IF @raccourci IS NULL
            EXEC dbo.pr_e5_refuser 50926, N'Rattachement refusé : le raccourci du site du cabinet n’est pas installé (paramètre RACCOURCI_SITE_CABINET).';
        SET @attendu = @raccourci + N'/Modeles/' + @fichier;
        IF NOT (ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM @chemin_coffre COLLATE Latin1_General_100_BIN2)), 0) = 0) AND LTRIM(RTRIM(@chemin_coffre)) <> @attendu
        BEGIN
            SET @m = N'Rattachement refusé : le fichier d’un gabarit se lit à « ' + LEFT(@attendu, 400) + N' » par le raccourci du coffre, et non à « '
                   + LEFT(LTRIM(RTRIM(@chemin_coffre)), 400) + N' ».';
            EXEC dbo.pr_e5_refuser 50926, @m;
        END;
        IF LEN(@attendu) > 400
        BEGIN
            SET @m = N'Rattachement refusé : l’emplacement « ' + LEFT(@attendu, 400) + N' » dépasse 400 caractères ; raccourcissez le nom du fichier.';
            EXEC dbo.pr_e5_refuser 50926, @m;
        END;
        SET @chemin = @attendu;
        -- 6. l'empreinte, calculee par la fonction sur les octets lus
        IF ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM @empreinte COLLATE Latin1_General_100_BIN2)), 0) = 0
            EXEC dbo.pr_e5_refuser 50927, N'Rattachement refusé : l’empreinte du fichier manque ; la fonction la calcule en lisant le fichier par le raccourci du coffre.';
        SET @empreinte = LOWER(LTRIM(RTRIM(@empreinte)));
        IF LEN(@empreinte) <> 64 OR @empreinte COLLATE Latin1_General_100_BIN2 LIKE N'%[^0-9a-f]%'
        BEGIN
            SET @m = N'Rattachement refusé : « ' + LEFT(@empreinte, 80) + N' » n’est pas une empreinte SHA-256, 64 caractères hexadécimaux.';
            EXEC dbo.pr_e5_refuser 50927, @m;
        END;
        -- 7. une valeur inchangee ne s'ecrit pas ; sinon l'inscription et le message
        IF @nom_avant = @fichier AND @chemin_avant = @chemin AND LOWER(@emp_avant) = @empreinte
        BEGIN
            SET @message = N'Aucune modification : le fichier « ' + @fichier + N' » est déjà rattaché au modèle « ' + @libelle_m + N' », avec la même empreinte.';
            EXEC dbo.pr_poser_message_ecran @pour = @par, @message = @message, @genre = 'SUCCES', @entite = '-', @procedure_nom = @proc;
            EXEC sp_set_session_context N'par', NULL;
            SELECT CAST('-' AS VARCHAR (20)) AS entite, @code AS modele, @fichier AS nom_fichier, @chemin AS chemin_coffre,
                   @empreinte AS empreinte_sha256, @web_url AS web_url, @message AS message;
            RETURN;
        END;
        BEGIN TRANSACTION;
        UPDATE dbo.modele_feuille SET nom_fichier = @fichier, chemin_coffre = @chemin, empreinte_sha256 = @empreinte WHERE code = @code;
        SET @message = N'Fichier « ' + @fichier + N' » rattaché au modèle de feuille « ' + @libelle_m + N' ».';
        EXEC dbo.pr_poser_message_ecran @pour = @par, @message = @message, @genre = 'SUCCES', @entite = '-', @procedure_nom = @proc;
        COMMIT TRANSACTION;
        EXEC sp_set_session_context N'par', NULL;
        SELECT CAST('-' AS VARCHAR (20)) AS entite, @code AS modele, @fichier AS nom_fichier, @chemin AS chemin_coffre,
               @empreinte AS empreinte_sha256, @web_url AS web_url, @message AS message;
    END TRY
    BEGIN CATCH
        SELECT @e_num = ERROR_NUMBER(), @e_msg = ERROR_MESSAGE();
        IF @tc = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        BEGIN TRY EXEC sp_set_session_context N'par', NULL; END TRY BEGIN CATCH END CATCH;
        -- une contrainte de la table se dit en francais par le libelle de sa colonne, jamais par son nom
        SET @e_fr = dbo.fn_e5_traduire_erreur(@e_num, @e_msg);
        -- un refus de garde (ROLLBACK, inscription, THROW) recu sous 266 ou 3609 : la ligne qu'un declencheur
        -- a inscrite pour @par depuis l'entree
        IF @e_fr IS NULL AND @e_num IN (266, 3609) AND @par IS NOT NULL
            SELECT TOP (1) @e_fr = j.message FROM dbo.journal_refus j
            WHERE j.id > @journal_avant AND j.procedure_nom LIKE 'tr[_]%' AND j.refuse_pour = LEFT(@par, 200)
            ORDER BY j.id DESC;
        SET @e_journal = ISNULL(@e_fr, @e_msg);
        EXEC dbo.pr_e5_conclure_refus @tc, @journal_avant, @proc, @par, '-', @e_journal;
        IF @e_fr IS NOT NULL EXEC dbo.pr_e5_refuser 50928, @e_fr;
        THROW;
    END CATCH;
END;

GO

