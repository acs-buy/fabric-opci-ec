

CREATE   PROCEDURE dbo.pr_valider_pour_client
    @entite VARCHAR (20),
    @arrete VARCHAR (20),
    @par    NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @m NVARCHAR (1200), @le DATE = CAST(SYSUTCDATETIME() AS DATE), @nature VARCHAR (14), @manquants NVARCHAR (800),
            @propose NVARCHAR (400), @ref VARCHAR (60) = @entite + '|' + @arrete, @ca_version INT;
    SELECT @nature = type_arrete FROM dbo.ref_arrete WHERE entite = @entite AND arrete = @arrete;

    IF NOT EXISTS (SELECT 1 FROM dbo.role_mission r WHERE r.entite = @entite AND (r.connexion = @par OR r.personne = @par)
                   AND r.role = 'CHEF_MISSION' AND r.du <= @le AND (r.au IS NULL OR r.au > @le))
        THROW 50616, N'Validation refusée : cette personne n''a pas, sur cette entité, le rôle de chef de mission.', 1;
    IF dbo.fn_valide_pour_client(@entite, @arrete) = 1
        THROW 50615, N'Validation refusée : l''arrêté est déjà validé pour le client.', 1;
    IF dbo.fn_revue_visee(@entite, @arrete) = 0 OR dbo.fn_dossier_verrouille(@entite, @arrete) = 0
        THROW 50612, N'Validation refusée : la revue de cet arrêté n''est pas visée.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.publication_vl p WHERE p.entite = @entite AND p.arrete = @arrete)
        THROW 50087, N'Validation refusée : la valeur liquidative de cet arrêté n''est pas publiée.', 1;
    IF @nature = 'ANNUEL'
    BEGIN
        DECLARE @non_visees INT = (SELECT COUNT(*) FROM dbo.obligation_distribution o
                                   WHERE o.entite = @entite AND YEAR(CONVERT(DATE, o.exercice)) = YEAR(CONVERT(DATE, @arrete))
                                     AND (o.etat IS NULL OR o.etat <> 'VISEE'));
        IF @non_visees > 0
        BEGIN
            SET @m = N'Validation refusée : ' + CAST(@non_visees AS NVARCHAR (10)) + N' catégorie(s) de sommes distribuables ne sont pas visées pour cet exercice. À l''arrêté annuel, les 3 catégories se visent avant la validation.';
            THROW 50088, @m, 1;
        END;
    END;
    SELECT @manquants = STRING_AGG(CAST(x.libelle AS NVARCHAR (200)), N', ')
    FROM (SELECT DISTINCT livrable, libelle FROM dbo.v_livrables_a_valider WHERE entite = @entite AND arrete = @arrete AND produit_complet = 0) x;
    IF @manquants IS NOT NULL
    BEGIN
        SET @m = N'Validation refusée : livrables dus non produits ou périmés : ' + @manquants + N'.';
        THROW 50613, @m, 1;
    END;
    IF EXISTS (SELECT 1 FROM dbo.v_livrables_a_valider WHERE entite = @entite AND arrete = @arrete AND livrable = 'ATTESTATION')
    BEGIN
        SELECT @ca_version = MAX(version) FROM dbo.document_produit WHERE entite = @entite AND arrete = @arrete AND livrable = 'COMPTES_ANNUELS';
        IF EXISTS (SELECT 1 FROM dbo.v_livrables_a_valider WHERE entite = @entite AND arrete = @arrete AND livrable = 'ATTESTATION'
                   AND ISNULL(couvre_version, -1) <> ISNULL(@ca_version, -2))
            THROW 50614, N'Validation refusée : le rapport de l''expert-comptable ne couvre pas la dernière version des comptes annuels.', 1;
    END;
    -- le proposant : l'auteur du Word de la derniere version des comptes annuels (annuel) ou du DIP (hors annuel)
    SELECT TOP (1) @propose = produit_par FROM dbo.v_livrables_a_valider
    WHERE entite = @entite AND arrete = @arrete AND format = 'DOCX'
      AND livrable = CASE WHEN @nature = 'ANNUEL' THEN 'COMPTES_ANNUELS' ELSE 'DIP' END;
    IF EXISTS (SELECT 1 FROM dbo.v_livrables_a_valider v
               WHERE v.entite = @entite AND v.arrete = @arrete
                 AND (v.produit_par = @par OR v.produit_par IN (SELECT r.personne FROM dbo.role_mission r WHERE r.connexion = @par AND r.entite = @entite)
                      OR v.produit_par IN (SELECT r.connexion FROM dbo.role_mission r WHERE r.personne = @par AND r.entite = @entite)))
        THROW 50617, N'Validation refusée : le décideur a produit les livrables validés ; nul ne valide son propre travail.', 1;

    INSERT INTO dbo.visa (nature, objet_ref, entite, arrete, cycle, decision, propose_par, decide_par, decide_le)
    VALUES ('CLOTURE', @ref, @entite, @arrete, NULL, 'VISE', @propose, @par, SYSUTCDATETIME());

    -- les fichiers a copier dans la bibliotheque « Livrables » du site du vehicule
    SELECT v.document_id, v.livrable, v.version, v.format, v.fichier, v.web_url,
           N'Arrêté validé pour le client ; ' + CAST(COUNT(*) OVER () AS NVARCHAR (10)) + N' fichier(s) à copier dans la bibliothèque Livrables du site.' AS message
    FROM dbo.v_livrables_a_valider v
    WHERE v.entite = @entite AND v.arrete = @arrete AND v.document_id IS NOT NULL
    ORDER BY v.livrable, v.format;
END;

GO

