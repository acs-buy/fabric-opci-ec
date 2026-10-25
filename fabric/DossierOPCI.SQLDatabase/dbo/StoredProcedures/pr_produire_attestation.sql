
-- pr_produire_attestation : 1 refus
CREATE   PROCEDURE dbo.pr_produire_attestation
    @entite  VARCHAR (20),
    @arrete  VARCHAR (20),
    @fichier NVARCHAR (400),
    @par     NVARCHAR (400),
    @empreinte_stockee CHAR (64) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- 327 debut (24/10/2026) : un champ vide se refuse en francais avant toute ecriture, au texte du champ dans le
    -- plan de l'etude des fonctions (decision A du candidat). Genere par 61_DEPLOIEMENT/generer_327_refus_champs_vides.py.
    -- Place : les selecteurs passent devant la garde de droit, qui se juge sur eux.
    -- le vide : les 29 caracteres de str.isspace(), compares au point de code
    DECLARE @r327_blancs NVARCHAR (29) = NCHAR(9) + NCHAR(10) + NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(28) + NCHAR(29) + NCHAR(30) + NCHAR(31) + NCHAR(32)
        + NCHAR(133) + NCHAR(160) + NCHAR(5760) + NCHAR(8192) + NCHAR(8193) + NCHAR(8194) + NCHAR(8195) + NCHAR(8196) + NCHAR(8197) + NCHAR(8198)
        + NCHAR(8199) + NCHAR(8200) + NCHAR(8201) + NCHAR(8202) + NCHAR(8232) + NCHAR(8233) + NCHAR(8239) + NCHAR(8287) + NCHAR(12288);
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @entite COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51201, N'Choisissez le véhicule dans le sélecteur Véhicule.', 1;
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @arrete COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51233, N'Production refusée : le rapport de l’expert-comptable ne se produit pas à cet arrêté en l''état ; il exige notamment la forme arrêtée, l''associé signataire, la revue visée et les comptes annuels produits.', 1;
    -- 327 fin
    DECLARE @m NVARCHAR (800);
    IF dbo.fn_peut_viser_nature(@entite, @par, 'PUBLICATION', CAST(SYSUTCDATETIME() AS DATE)) = 0
        THROW 50092, N'Production refusée : le rapport de l''expert-comptable est signé par l''associé signataire, et lui seul le produit.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.attestation a WHERE a.entite = @entite AND a.arrete = @arrete AND a.arretee_le IS NOT NULL)
        THROW 50093, N'Production refusée : la forme du rapport de l''expert-comptable n''est pas arrêtée pour cet arrêté.', 1;
    IF dbo.fn_revue_visee(@entite, @arrete) = 0
        THROW 50619, N'Production refusée : la revue de cet arrêté n''est pas visée.', 1;
    IF dbo.fn_valide_pour_client(@entite, @arrete) = 1
        THROW 50620, N'Production refusée : l''arrêté est validé pour le client ; une nouvelle version suppose sa réouverture.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.demande_document dd
                   WHERE dd.entite = @entite AND dd.arrete = @arrete AND dd.livrable = 'COMPTES_ANNUELS' AND dd.etat = 'PRODUITE'
                     AND dd.version = (SELECT MAX(d.version) FROM dbo.document_produit d
                                       WHERE d.entite = @entite AND d.arrete = @arrete AND d.livrable = 'COMPTES_ANNUELS')
                     AND NOT EXISTS (SELECT 1 FROM dbo.document_produit d
                                     WHERE d.entite = @entite AND d.arrete = @arrete AND d.livrable = 'COMPTES_ANNUELS'
                                       AND d.version = dd.version AND d.perime_le IS NOT NULL))
        THROW 50618, N'Production refusée : les comptes annuels de cet arrêté ne sont pas produits, ou leur dernière version est périmée.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.export_dossier WHERE entite = @entite AND arrete = @arrete AND sous_dossier = N'Livrables'
                   AND fichier = @fichier AND statut = 'FAIT')
    BEGIN
        SET @m = N'Production refusée : le fichier ' + ISNULL(@fichier, N'(vide)') + N' du rapport de l''expert-comptable n''a aucun dépôt connu dans le dossier Livrables de cet arrêté.';
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50623, @m, 1; END
    END;
    EXEC dbo.pr_enregistrer_document @entite, @arrete, 'ATTESTATION', @fichier, @par, @empreinte_stockee;
END;

GO

