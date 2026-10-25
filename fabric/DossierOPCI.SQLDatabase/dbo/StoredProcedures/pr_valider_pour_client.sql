-- pr_valider_pour_client : 3 refus
-- les lecteurs qui testent qu'une VL est publiee ne comptent que la publication en vigueur

-- ------------------------------------------------------------------------------------------------- validation
-- La validation pour le client (contrat, 2.4 et 3.1, point 5) : verrou, calcul VALIDATION, gardes, visa de cloture qui
-- porte la derniere version. Un document COMPTES_ANNUELS ou ATTESTATION sans version de l'annexe ne compte pas comme
-- produit (2.2, point 7). Un document que le calcul perime fait refuser la validation (50613), calcul compris.
CREATE   PROCEDURE dbo.pr_valider_pour_client
    @entite VARCHAR (20),
    @arrete VARCHAR (20),
    @par    NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @m NVARCHAR (1200), @le DATE = CAST(SYSUTCDATETIME() AS DATE), @nature VARCHAR (14), @manquants NVARCHAR (800),
            @propose NVARCHAR (400), @ref VARCHAR (60) = @entite + '|' + @arrete, @ca_version INT, @tc INT = @@TRANCOUNT,
            @perimes INT = 0, @calcul INT, @debut DATETIME2 (3), @derniere INT;
    BEGIN TRY
    BEGIN TRANSACTION;
    EXEC dbo.pr_ann_verrou @entite = @entite;
    SET @debut = SYSUTCDATETIME();
    IF EXISTS (SELECT 1 FROM dbo.v_arrete_etat WHERE entite = @entite AND arrete = @arrete)
        EXEC dbo.pr_calculer_annexe @entite = @entite, @arrete = @arrete, @declencheur = 'VALIDATION', @par = @par, @rendre = 0,
             @documents_perimes = @perimes OUTPUT, @calcul_id = @calcul OUTPUT;
    SELECT @nature = type_arrete FROM dbo.ref_arrete WHERE entite = @entite AND arrete = @arrete;

    IF NOT EXISTS (SELECT 1 FROM dbo.role_mission r WHERE r.entite = @entite AND (r.connexion = @par OR r.personne = @par)
                   AND r.role = 'CHEF_MISSION' AND r.du <= @le AND (r.au IS NULL OR r.au > @le))
        THROW 50616, N'Validation refusée : cette personne n''a pas, sur cette entité, le rôle de chef de mission.', 1;
    IF dbo.fn_valide_pour_client(@entite, @arrete) = 1
        THROW 50615, N'Validation refusée : l''arrêté est déjà validé pour le client.', 1;
    IF dbo.fn_revue_visee(@entite, @arrete) = 0 OR dbo.fn_dossier_verrouille(@entite, @arrete) = 0
        THROW 50612, N'Validation refusée : la revue de cet arrêté n''est pas visée.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.publication_vl p WHERE p.entite = @entite AND p.arrete = @arrete AND p.perimee_le IS NULL)
        THROW 50087, N'Validation refusée : la valeur liquidative de cet arrêté n''est pas publiée.', 1;
    IF @nature = 'ANNUEL'
    BEGIN
        -- Decision du candidat du 18/10/2026 : chaque categorie du referentiel doit avoir sa ligne VISEE ; une categorie
        -- absente compte comme non visee (auparavant, 0 ligne laissait passer la validation).
        DECLARE @non_visees INT = (SELECT COUNT(*) FROM dbo.ref_obligation_distribution r
                                   WHERE NOT EXISTS (SELECT 1 FROM dbo.v_obligation_par_categorie v
                                                     WHERE v.entite = @entite AND v.arrete = @arrete
                                                       AND v.categorie_ref = r.categorie AND v.etat_obligation = 'VISEE'));
        IF @non_visees > 0
        BEGIN
            SET @m = N'Validation refusée : ' + CAST(@non_visees AS NVARCHAR (10))
                 + CASE WHEN @non_visees = 1 THEN N' catégorie de sommes distribuables n''est pas visée' ELSE N' catégories de sommes distribuables ne sont pas visées' END
                 + N' pour cet exercice. À l''arrêté annuel, les 3 catégories se visent avant la validation.';
            BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50088, @m, 1; END
        END;
    END;
    -- les documents que le calcul de cette validation a perimes : le message le dit et invite a recalculer
    IF @perimes > 0
    BEGIN
        DECLARE @libs NVARCHAR (800), @vmin INT;
        SELECT @libs = STRING_AGG(CAST(l.libelle AS NVARCHAR (200)), N', '), @vmin = MIN(x.annexe_version)
        FROM (SELECT livrable, MIN(annexe_version) AS annexe_version FROM dbo.document_produit
              WHERE entite = @entite AND arrete = @arrete AND perime_le >= @debut AND livrable IN ('COMPTES_ANNUELS', 'ATTESTATION')
              GROUP BY livrable) x
        JOIN dbo.ref_livrable l ON l.code = x.livrable;
        SET @derniere = (SELECT derniere_version FROM dbo.v_annexe_version WHERE entite = @entite AND arrete = @arrete);
        SET @m = N'Validation refusée : l''annexe a changé depuis la production de ' + ISNULL(@libs, N'livrables') + N' (version '
               + ISNULL(CAST(@vmin AS NVARCHAR (10)), N'?') + N' de l''annexe, dernière version ' + ISNULL(CAST(@derniere AS NVARCHAR (10)), N'?')
               + N') ; recalculez avec le bouton « Recalculer », puis produisez de nouveau ces livrables.';
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50613, @m, 1; END
    END;
    -- un livrable dont les fichiers ne portent pas de version de l'annexe ne compte pas comme produit
    SELECT @manquants = STRING_AGG(CAST(x.libelle AS NVARCHAR (200)), N', ')
    FROM (SELECT DISTINCT v.livrable, v.libelle FROM dbo.v_livrables_a_valider v
          WHERE v.entite = @entite AND v.arrete = @arrete
            AND (v.produit_complet = 0
                 OR (v.livrable IN ('COMPTES_ANNUELS', 'ATTESTATION')
                     AND EXISTS (SELECT 1 FROM dbo.document_produit p WHERE p.entite = v.entite AND p.arrete = v.arrete AND p.livrable = v.livrable
                                 AND p.version = v.version AND p.perime_le IS NULL AND p.annexe_version IS NULL)))) x;
    IF @manquants IS NOT NULL
    BEGIN
        SET @m = N'Validation refusée : livrables dus non produits ou périmés : ' + @manquants + N'.';
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50613, @m, 1; END
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

    -- le visa de cloture porte la derniere version de l'annexe (contrat, 2.4, point 2)
    SET @derniere = (SELECT derniere_version FROM dbo.v_annexe_version WHERE entite = @entite AND arrete = @arrete);
    INSERT INTO dbo.visa (nature, objet_ref, entite, arrete, cycle, decision, propose_par, decide_par, decide_le, annexe_version)
    VALUES ('CLOTURE', @ref, @entite, @arrete, NULL, 'VISE', @propose, @par, SYSUTCDATETIME(), @derniere);
    COMMIT;
    END TRY
    BEGIN CATCH
        IF @tc = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    -- les fichiers a copier dans la bibliotheque « Livrables » du site du vehicule
    SELECT v.document_id, v.livrable, v.version, v.format, v.fichier, v.web_url,
           N'Arrêté validé pour le client ; ' + CAST(COUNT(*) OVER () AS NVARCHAR (10)) + N' fichier(s) à copier dans la bibliothèque Livrables du site.' AS message
    FROM dbo.v_livrables_a_valider v
    WHERE v.entite = @entite AND v.arrete = @arrete AND v.document_id IS NOT NULL
    ORDER BY v.livrable, v.format;
END;

GO

