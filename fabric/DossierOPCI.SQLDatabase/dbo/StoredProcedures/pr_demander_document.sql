
-- La demande d'un document, en 2 temps (contrat, 3.1, point 3) : verrou, gardes, numero de la demande, calcul pour les
-- comptes annuels et le rapport, obstacles de l'annexe. Un refus enregistre la demande REFUSEE sans lever d'erreur : le
-- calcul est valide avec elle.
CREATE   PROCEDURE dbo.pr_demander_document
    @entite   VARCHAR (20),
    @arrete   VARCHAR (20),
    @livrable VARCHAR (20),
    @par      NVARCHAR (400) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    -- 327 debut (24/10/2026) : un champ vide se refuse en francais avant toute ecriture, au texte du champ dans le
    -- plan de l'etude des fonctions (decision A du candidat). Genere par 61_DEPLOIEMENT/generer_327_refus_champs_vides.py.
    -- Place : avant la transaction : aucune demande ne s'ecrit pour un champ vide.
    -- le vide : les 29 caracteres de str.isspace(), compares au point de code
    DECLARE @r327_blancs NVARCHAR (29) = NCHAR(9) + NCHAR(10) + NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(28) + NCHAR(29) + NCHAR(30) + NCHAR(31) + NCHAR(32)
        + NCHAR(133) + NCHAR(160) + NCHAR(5760) + NCHAR(8192) + NCHAR(8193) + NCHAR(8194) + NCHAR(8195) + NCHAR(8196) + NCHAR(8197) + NCHAR(8198)
        + NCHAR(8199) + NCHAR(8200) + NCHAR(8201) + NCHAR(8202) + NCHAR(8232) + NCHAR(8233) + NCHAR(8239) + NCHAR(8287) + NCHAR(12288);
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @entite COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51201, N'Choisissez le véhicule dans le sélecteur Véhicule.', 1;
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @livrable COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51232, N'Production refusée : choisissez le livrable dans la liste « 1. Livrables de l’arrêté ».', 1;
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @arrete COLLATE Latin1_General_100_BIN2)), 0) = 0
    BEGIN
        IF @livrable = 'ATTESTATION'
            THROW 51233, N'Production refusée : le rapport de l’expert-comptable ne se produit pas à cet arrêté en l''état ; il exige notamment la forme arrêtée, l''associé signataire, la revue visée et les comptes annuels produits.', 1;
        THROW 51234, N'Production refusée : aucun arrêté n''est désigné pour le livrable choisi ; l''action n''est pas exécutée.', 1;
    END;
    -- 327 fin
    DECLARE @qui NVARCHAR (400) = ISNULL(@par, SUSER_SNAME()), @tc INT = @@TRANCOUNT, @version INT, @motif NVARCHAR (2000), @id INT;
    BEGIN TRY
    BEGIN TRANSACTION;
    EXEC dbo.pr_ann_verrou @entite = @entite;
    SET @motif = dbo.fn_garde_production(@entite, @arrete, @livrable, @qui);
    -- la version suivante, sur les demandes ET les documents deja produits du meme livrable et du meme arrete
    SET @version = (SELECT MAX(v) FROM (
                        SELECT version AS v FROM dbo.demande_document WHERE entite = @entite AND arrete = @arrete AND livrable = @livrable
                        UNION ALL
                        SELECT version FROM dbo.document_produit WHERE entite = @entite AND arrete = @arrete AND livrable = @livrable
                        UNION ALL SELECT 0) x) + 1;
    IF @motif IS NULL AND @livrable IN ('COMPTES_ANNUELS', 'ATTESTATION')
       AND EXISTS (SELECT 1 FROM dbo.v_arrete_etat WHERE entite = @entite AND arrete = @arrete)
    BEGIN
        EXEC dbo.pr_calculer_annexe @entite = @entite, @arrete = @arrete, @declencheur = 'PRODUCTION', @par = @qui, @rendre = 0;
        SET @motif = dbo.fn_obstacle_annexe(@entite, @arrete, @livrable);
    END;
    IF @motif IS NOT NULL
        SET @motif = N'Production refusée : ' + @motif;
    INSERT INTO dbo.demande_document (entite, arrete, livrable, version, demande_par, etat, motif_refus)
    VALUES (@entite, @arrete, @livrable, @version, @qui, CASE WHEN @motif IS NULL THEN 'DEMANDEE' ELSE 'REFUSEE' END, @motif);
    SET @id = SCOPE_IDENTITY();
    COMMIT;
    END TRY
    BEGIN CATCH
        IF @tc = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
    SELECT @id AS demande_id, @version AS version,
           CASE WHEN @motif IS NULL THEN 'DEMANDEE' ELSE 'REFUSEE' END AS etat,
           ISNULL(@motif, N'la demande est enregistrée : la fonction de production peut écrire le document') AS lecture;
END;

GO

