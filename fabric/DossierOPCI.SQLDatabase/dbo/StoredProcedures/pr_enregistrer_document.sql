

CREATE   PROCEDURE dbo.pr_enregistrer_document
    @entite   VARCHAR (20),
    @arrete   VARCHAR (20),
    @livrable VARCHAR (20),
    @fichier  NVARCHAR (400),
    @par      NVARCHAR (400),
    @empreinte_stockee CHAR (64) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @m NVARCHAR (800), @depot INT, @web NVARCHAR (800), @emp CHAR (64), @taille INT, @le DATETIME2,
            @demande INT, @version INT, @format VARCHAR (4), @formats VARCHAR (40), @id INT, @manquants INT;

    SELECT TOP (1) @depot = id, @web = web_url, @emp = empreinte_sha256, @taille = taille, @le = depose_le
    FROM dbo.export_dossier
    WHERE entite = @entite AND arrete = @arrete AND sous_dossier = N'Livrables' AND fichier = @fichier AND statut = 'FAIT'
    ORDER BY id DESC;
    IF @depot IS NULL
    BEGIN
        SET @m = N'Enregistrement refusé : le fichier ' + ISNULL(@fichier, N'vide') + N' n''a aucun dépôt connu dans le dossier Livrables de cet arrêté.';
        THROW 50610, @m, 1;
    END;
    -- UN FICHIER DEJA ENREGISTRE se reconnait avant la demande en cours, qui peut etre deja PRODUITE : le rappel ne cree
    -- rien, il complete seulement l'empreinte de la copie stockee si elle manquait.
    SELECT @id = id, @version = version, @format = format FROM dbo.document_produit
    WHERE entite = @entite AND arrete = @arrete AND livrable = @livrable AND fichier = @fichier;
    IF @id IS NOT NULL
    BEGIN
        IF @empreinte_stockee IS NOT NULL
            UPDATE dbo.document_produit SET empreinte_stockee = LOWER(@empreinte_stockee), empreinte_stockee_le = SYSUTCDATETIME()
            WHERE id = @id AND empreinte_stockee IS NULL;
        SELECT d.id AS document_id, d.version, d.format, d.web_url, d.empreinte_sha256, d.empreinte_stockee,
               CAST(CASE WHEN dd.etat = 'PRODUITE' THEN 1 ELSE 0 END AS BIT) AS demande_produite,
               N'Fichier ' + @fichier + N' déjà enregistré, version ' + CAST(d.version AS NVARCHAR (10)) + N' : rien de nouveau.' AS message
        FROM dbo.document_produit d
        LEFT JOIN dbo.demande_document dd ON dd.entite = d.entite AND dd.arrete = d.arrete AND dd.livrable = d.livrable AND dd.version = d.version
        WHERE d.id = @id;
        RETURN;
    END;
    SELECT TOP (1) @demande = id, @version = version FROM dbo.demande_document
    WHERE entite = @entite AND arrete = @arrete AND livrable = @livrable AND etat = 'DEMANDEE'
    ORDER BY version DESC;
    IF @demande IS NULL
        THROW 50611, N'Enregistrement refusé : aucune demande en cours pour ce livrable et cet arrêté.', 1;
    -- les conditions de la demande valent au moment de l'enregistrement
    SET @m = dbo.fn_obstacle_production(@entite, @arrete, @livrable, @par);
    IF @m IS NOT NULL
    BEGIN
        SET @m = N'Enregistrement refusé : ' + @m;
        THROW 50634, @m, 1;
    END;
    -- le rapport suppose sa forme arretee, et couvre la derniere version des comptes annuels, produite et non
    -- perimee (la garde de la demande l'a verifie).
    DECLARE @ca_version INT;
    IF @livrable = 'ATTESTATION'
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM dbo.attestation WHERE entite = @entite AND arrete = @arrete AND arretee_le IS NOT NULL)
            THROW 50093, N'Production refusée : la forme du rapport de l''expert-comptable n''est pas arrêtée pour cet arrêté.', 1;
        SELECT @ca_version = MAX(version) FROM dbo.document_produit WHERE entite = @entite AND arrete = @arrete AND livrable = 'COMPTES_ANNUELS';
    END;

    SET @format = UPPER(RIGHT(@fichier, CHARINDEX('.', REVERSE(@fichier) + '.') - 1));
    SELECT @formats = formats FROM dbo.ref_livrable WHERE code = @livrable;
    IF @format = '' OR @formats IS NULL OR CHARINDEX(',' + @format + ',', ',' + @formats + ',') = 0
    BEGIN
        SET @m = N'Enregistrement refusé : le format ' + ISNULL(NULLIF(@format, ''), N'sans extension') + N' n''est pas attendu pour ce livrable ; formats attendus : '
               + ISNULL(REPLACE(@formats, ',', ', '), N'aucun') + N'.';
        THROW 50624, @m, 1;
    END;
    IF @fichier NOT LIKE N'%[_]v' + CAST(@version AS NVARCHAR (10)) + N'.%'
    BEGIN
        SET @m = N'Enregistrement refusé : le nom du fichier ' + @fichier + N' ne porte pas la version ' + CAST(@version AS NVARCHAR (10)) + N' de la demande en cours.';
        THROW 50625, @m, 1;
    END;
    IF @emp IS NULL OR LEN(@emp) <> 64
        THROW 50627, N'Dépôt refusé : un livrable se dépose avec l''empreinte de son fichier.', 1;

    SELECT @id = id FROM dbo.document_produit WHERE entite = @entite AND arrete = @arrete AND livrable = @livrable AND version = @version AND format = @format;
    BEGIN TRANSACTION;
    IF @id IS NULL
    BEGIN
        INSERT INTO dbo.document_produit (entite, arrete, livrable, version, format, fichier, web_url, empreinte_sha256, produit_par, produit_le,
                                          empreinte_stockee, empreinte_stockee_le, couvre_version)
        VALUES (@entite, @arrete, @livrable, @version, @format, @fichier, @web, @emp, @par, @le,
                LOWER(@empreinte_stockee), CASE WHEN @empreinte_stockee IS NOT NULL THEN SYSUTCDATETIME() END, @ca_version);
        SET @id = SCOPE_IDENTITY();
        IF @livrable = 'ATTESTATION'
        BEGIN
            -- chaque fichier des comptes annuels couverts, avec son empreinte
            INSERT INTO dbo.document_couverture (document_id, document_couvert_id, empreinte_couverte)
            SELECT @id, d.id, d.empreinte_sha256 FROM dbo.document_produit d
            WHERE d.entite = @entite AND d.arrete = @arrete AND d.livrable = 'COMPTES_ANNUELS' AND d.version = @ca_version;
            UPDATE dbo.attestation SET produit_par = @par, produit_le = @le WHERE entite = @entite AND arrete = @arrete;
        END;
        IF @livrable = 'COMPTES_ANNUELS'
            -- une nouvelle version des comptes annuels perime le rapport qui couvrait la precedente
            UPDATE dbo.document_produit
            SET perime_le = SYSUTCDATETIME(),
                perime_motif = N'Périmé : les comptes annuels de l''arrêté passent en version ' + CAST(@version AS NVARCHAR (10))
                             + N', ce rapport couvrait la version ' + CAST(couvre_version AS NVARCHAR (10)) + N' ; par ' + @par
                             + N', le ' + CONVERT(NVARCHAR (19), SYSUTCDATETIME(), 120) + N' UTC.'
            WHERE entite = @entite AND arrete = @arrete AND livrable = 'ATTESTATION' AND perime_le IS NULL AND couvre_version < @version;
    END
    ELSE IF @empreinte_stockee IS NOT NULL
        UPDATE dbo.document_produit SET empreinte_stockee = LOWER(@empreinte_stockee), empreinte_stockee_le = SYSUTCDATETIME()
        WHERE id = @id AND empreinte_stockee IS NULL;
    SELECT @manquants = COUNT(*)
    FROM STRING_SPLIT(@formats, ',') f
    WHERE NOT EXISTS (SELECT 1 FROM dbo.document_produit d WHERE d.entite = @entite AND d.arrete = @arrete AND d.livrable = @livrable
                        AND d.version = @version AND d.format = LTRIM(RTRIM(f.value)));
    IF @manquants = 0
        UPDATE dd SET etat = 'PRODUITE',
                      produit_le = (SELECT MAX(produit_le) FROM dbo.document_produit d WHERE d.entite = dd.entite AND d.arrete = dd.arrete AND d.livrable = dd.livrable AND d.version = dd.version),
                      taille_octets = (SELECT SUM(x.taille) FROM dbo.document_produit d
                                       JOIN dbo.export_dossier x ON x.entite = d.entite AND x.arrete = d.arrete AND x.sous_dossier = N'Livrables'
                                                                AND x.fichier = d.fichier AND x.statut = 'FAIT'
                                       WHERE d.entite = dd.entite AND d.arrete = dd.arrete AND d.livrable = dd.livrable AND d.version = dd.version)
        FROM dbo.demande_document dd WHERE dd.id = @demande;
    COMMIT;

    SELECT @id AS document_id, @version AS version, @format AS format, @web AS web_url, @emp AS empreinte_sha256,
           LOWER(@empreinte_stockee) AS empreinte_stockee,
           CAST(CASE WHEN @manquants = 0 THEN 1 ELSE 0 END AS BIT) AS demande_produite,
           N'Fichier ' + @fichier + N' enregistré, version ' + CAST(@version AS NVARCHAR (10)) + N', format ' + @format
         + CASE WHEN @manquants = 0 THEN N' ; chaque format attendu est produit, la demande passe à PRODUITE.'
                ELSE N' ; ' + CAST(@manquants AS NVARCHAR (4)) + N' format(s) attendu(s) restent à produire.' END AS message;
END;

GO

