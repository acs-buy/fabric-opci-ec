
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

