
-- pr_enregistrer_document : 6 refus
-- L'enregistrement d'un document produit (contrat, 3.3, point 12) : verrou partage au debut ; gardes de la production et
-- obstacles de l'annexe (50634) ; pour COMPTES_ANNUELS, la version de l'annexe lue par le document (50648) ; pour les 2
-- livrables, aucune marque de retard (50649). Le rapport recoit la version des comptes annuels qu'il couvre.
CREATE   PROCEDURE dbo.pr_enregistrer_document
    @entite   VARCHAR (20),
    @arrete   VARCHAR (20),
    @livrable VARCHAR (20),
    @fichier  NVARCHAR (400),
    @par      NVARCHAR (400),
    @empreinte_stockee CHAR (64) = NULL,
    @annexe_version INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @m NVARCHAR (800), @depot INT, @web NVARCHAR (800), @emp CHAR (64), @taille INT, @le DATETIME2,
            @demande INT, @version INT, @format VARCHAR (4), @formats VARCHAR (40), @id INT, @manquants INT, @tc INT = @@TRANCOUNT,
            @av INT, @derniere INT, @autre_format VARCHAR (4), @autre_v INT, @rappel BIT = 0;
    BEGIN TRY
    BEGIN TRANSACTION;
    EXEC dbo.pr_ann_verrou @entite = @entite, @mode = 'Shared';

    SELECT TOP (1) @depot = id, @web = web_url, @emp = empreinte_sha256, @taille = taille, @le = depose_le
    FROM dbo.export_dossier
    WHERE entite = @entite AND arrete = @arrete AND sous_dossier = N'Livrables' AND fichier = @fichier AND statut = 'FAIT'
    ORDER BY id DESC;
    IF @depot IS NULL
    BEGIN
        SET @m = N'Enregistrement refusé : le fichier ' + ISNULL(@fichier, N'vide') + N' n''a aucun dépôt connu dans le dossier Livrables de cet arrêté.';
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50610, @m, 1; END
    END;
    -- UN FICHIER DEJA ENREGISTRE se reconnait avant la demande en cours : le rappel ne cree rien, il complete seulement
    -- l'empreinte de la copie stockee si elle manquait (sans garde, contrat, 3.3, point 12).
    SELECT @id = id, @version = version, @format = format FROM dbo.document_produit
    WHERE entite = @entite AND arrete = @arrete AND livrable = @livrable AND fichier = @fichier;
    IF @id IS NOT NULL
    BEGIN
        IF @empreinte_stockee IS NOT NULL
            UPDATE dbo.document_produit SET empreinte_stockee = LOWER(@empreinte_stockee), empreinte_stockee_le = SYSUTCDATETIME()
            WHERE id = @id AND empreinte_stockee IS NULL;
        SET @rappel = 1;
    END
    ELSE
    BEGIN
        SELECT TOP (1) @demande = id, @version = version FROM dbo.demande_document
        WHERE entite = @entite AND arrete = @arrete AND livrable = @livrable AND etat = 'DEMANDEE'
        ORDER BY version DESC;
        IF @demande IS NULL
            THROW 50611, N'Enregistrement refusé : aucune demande en cours pour ce livrable et cet arrêté.', 1;
        -- les conditions de la demande valent au moment de l'enregistrement
        SET @m = ISNULL(dbo.fn_garde_production(@entite, @arrete, @livrable, @par), dbo.fn_obstacle_annexe(@entite, @arrete, @livrable));
        IF @m IS NOT NULL
        BEGIN
            SET @m = N'Enregistrement refusé : ' + @m;
            BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50634, @m, 1; END
        END;
        -- la version de l'annexe que le document imprime
        SET @derniere = (SELECT derniere_version FROM dbo.v_annexe_version WHERE entite = @entite AND arrete = @arrete);
        IF @livrable = 'COMPTES_ANNUELS'
        BEGIN
            IF @annexe_version IS NULL
                THROW 50648, N'Document refusé : la version de l''annexe lue par le document n''est pas donnée.', 1;
            IF @derniere IS NOT NULL AND @annexe_version < @derniere
            BEGIN
                SET @m = N'Document refusé : l''annexe de l''arrêté ' + @arrete + N' est passée en version ' + CAST(@derniere AS NVARCHAR (10))
                       + N' après la lecture du document (version ' + CAST(@annexe_version AS NVARCHAR (10)) + N') ; produisez-le de nouveau.';
                BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50648, @m, 1; END
            END;
            SELECT TOP (1) @autre_format = format, @autre_v = annexe_version FROM dbo.document_produit
            WHERE entite = @entite AND arrete = @arrete AND livrable = @livrable AND version = @version
              AND ISNULL(annexe_version, -1) <> @annexe_version
            ORDER BY id;
            IF @autre_format IS NOT NULL
            BEGIN
                SET @m = N'Document refusé : le format ' + @autre_format + N' de ce document porte la version '
                       + ISNULL(CAST(@autre_v AS NVARCHAR (10)), N'inconnue') + N' de l''annexe ; produisez une version neuve du document.';
                BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50648, @m, 1; END
            END;
            SET @av = @annexe_version;
        END;
        -- une marque de retard validee pour l'entite, lue par une lecture ordinaire
        IF @livrable IN ('COMPTES_ANNUELS', 'ATTESTATION')
        BEGIN
            SET @m = dbo.fn_ann_texte_retard(@entite);
            IF @m IS NOT NULL
            BEGIN
                SET @m = REPLACE(@m, N'%', N'%%');
                THROW 50649, @m, 1;
            END;
        END;
        -- le rapport suppose sa forme arretee, et couvre la derniere version des comptes annuels
        DECLARE @ca_version INT;
        IF @livrable = 'ATTESTATION'
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.attestation WHERE entite = @entite AND arrete = @arrete AND arretee_le IS NOT NULL)
                THROW 50093, N'Production refusée : la forme du rapport de l''expert-comptable n''est pas arrêtée pour cet arrêté.', 1;
            SELECT @ca_version = MAX(version) FROM dbo.document_produit WHERE entite = @entite AND arrete = @arrete AND livrable = 'COMPTES_ANNUELS';
            SET @av = (SELECT MAX(annexe_version) FROM dbo.document_produit
                       WHERE entite = @entite AND arrete = @arrete AND livrable = 'COMPTES_ANNUELS' AND version = @ca_version);
        END;

        SET @format = UPPER(RIGHT(@fichier, CHARINDEX('.', REVERSE(@fichier) + '.') - 1));
        SELECT @formats = formats FROM dbo.ref_livrable WHERE code = @livrable;
        IF @format = '' OR @formats IS NULL OR CHARINDEX(',' + @format + ',', ',' + @formats + ',') = 0
        BEGIN
            SET @m = N'Enregistrement refusé : le format ' + ISNULL(NULLIF(@format, ''), N'sans extension') + N' n''est pas attendu pour ce livrable ; formats attendus : '
                   + ISNULL(REPLACE(@formats, ',', ', '), N'aucun') + N'.';
            BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50624, @m, 1; END
        END;
        IF @fichier NOT LIKE N'%[_]v' + CAST(@version AS NVARCHAR (10)) + N'.%'
        BEGIN
            SET @m = N'Enregistrement refusé : le nom du fichier ' + @fichier + N' ne porte pas la version ' + CAST(@version AS NVARCHAR (10)) + N' de la demande en cours.';
            BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50625, @m, 1; END
        END;
        IF @emp IS NULL OR LEN(@emp) <> 64
            THROW 50627, N'Dépôt refusé : un livrable se dépose avec l''empreinte de son fichier.', 1;

        SELECT @id = id FROM dbo.document_produit WHERE entite = @entite AND arrete = @arrete AND livrable = @livrable AND version = @version AND format = @format;
        IF @id IS NULL
        BEGIN
            INSERT INTO dbo.document_produit (entite, arrete, livrable, version, format, fichier, web_url, empreinte_sha256, produit_par, produit_le,
                                              empreinte_stockee, empreinte_stockee_le, couvre_version, annexe_version)
            VALUES (@entite, @arrete, @livrable, @version, @format, @fichier, @web, @emp, @par, @le,
                    LOWER(@empreinte_stockee), CASE WHEN @empreinte_stockee IS NOT NULL THEN SYSUTCDATETIME() END, @ca_version, @av);
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
                -- une nouvelle version des comptes annuels perime le rapport qui couvrait la precedente (contrat, 2.3, point 8)
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
    END;
    COMMIT;
    END TRY
    BEGIN CATCH
        IF @tc = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    IF @rappel = 1
        SELECT d.id AS document_id, d.version, d.format, d.web_url, d.empreinte_sha256, d.empreinte_stockee,
               CAST(CASE WHEN dd.etat = 'PRODUITE' THEN 1 ELSE 0 END AS BIT) AS demande_produite,
               N'Fichier ' + @fichier + N' déjà enregistré, version ' + CAST(d.version AS NVARCHAR (10)) + N' : rien de nouveau.' AS message
        FROM dbo.document_produit d
        LEFT JOIN dbo.demande_document dd ON dd.entite = d.entite AND dd.arrete = d.arrete AND dd.livrable = d.livrable AND dd.version = d.version
        WHERE d.id = @id;
    ELSE
        SELECT @id AS document_id, @version AS version, @format AS format, @web AS web_url, @emp AS empreinte_sha256,
               LOWER(@empreinte_stockee) AS empreinte_stockee,
               CAST(CASE WHEN @manquants = 0 THEN 1 ELSE 0 END AS BIT) AS demande_produite,
               N'Fichier ' + @fichier + N' enregistré, version ' + CAST(@version AS NVARCHAR (10)) + N', format ' + @format
             + CASE WHEN @manquants = 0 THEN N' ; chaque format attendu est produit, la demande passe à PRODUITE.'
                    ELSE N' ; ' + CAST(@manquants AS NVARCHAR (4)) + N' format(s) attendu(s) restent à produire.' END AS message;
END;

GO

