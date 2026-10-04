
CREATE   PROCEDURE dbo.pr_produire_attestation
    @entite  VARCHAR (20),
    @arrete  VARCHAR (20),
    @fichier NVARCHAR (400),
    @par     NVARCHAR (400),
    @empreinte_stockee CHAR (64) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @m NVARCHAR (800);
    IF dbo.fn_peut_viser_nature(@entite, @par, 'PUBLICATION', CAST(SYSUTCDATETIME() AS DATE)) = 0
        THROW 50092, N'Production refusée : le rapport de l''expert-comptable est signé par l''associé signataire, et lui seul le produit.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.attestation a WHERE a.entite = @entite AND a.arrete = @arrete AND a.arretee_le IS NOT NULL)
        THROW 50093, N'Production refusée : la forme du rapport de l''expert-comptable n''est pas arrêtée pour cet arrêté.', 1;
    IF dbo.fn_revue_visee(@entite, @arrete) = 0
        THROW 50619, N'Production refusée : la revue de cet arrêté n''est pas visée.', 1;
    IF (SELECT TOP (1) decision FROM dbo.visa WHERE nature = 'CLOTURE' AND entite = @entite AND arrete = @arrete
        ORDER BY decide_le DESC, id DESC) = 'VISE'
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
        THROW 50623, @m, 1;
    END;
    EXEC dbo.pr_enregistrer_document @entite, @arrete, 'ATTESTATION', @fichier, @par, @empreinte_stockee;
END;

GO

