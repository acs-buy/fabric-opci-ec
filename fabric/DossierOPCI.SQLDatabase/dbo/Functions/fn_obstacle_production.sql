

-- LE RAPPORT DE L'EXPERT-COMPTABLE SUPPOSE LES COMPTES ANNUELS PRODUITS : ATTESTATION est refusee tant que la
-- derniere version de COMPTES_ANNUELS de l'arrete n'est pas PRODUITE, ou qu'un de ses fichiers est perime.
CREATE   FUNCTION dbo.fn_obstacle_production (
    @entite   VARCHAR (20),
    @arrete   VARCHAR (20),
    @livrable VARCHAR (20),
    @par      NVARCHAR (400)
)
RETURNS NVARCHAR (2000)
AS
BEGIN
    DECLARE @le DATE = CAST(SYSUTCDATETIME() AS DATE), @bloquantes INT, @articles NVARCHAR (1000);
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_livrable WHERE code = @livrable)
        RETURN N'livrable inconnu : ' + ISNULL(@livrable, N'vide') + N'.';
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_arrete WHERE entite = @entite AND arrete = @arrete)
        RETURN N'arrêté inconnu pour cette entité.';
    IF NOT EXISTS (SELECT 1 FROM dbo.role_mission r
                   WHERE r.entite = @entite AND (r.connexion = @par OR r.personne = @par)
                     AND r.du <= @le AND (r.au IS NULL OR r.au > @le))
        RETURN N'cette personne ne tient aucun rôle de mission sur l''entité ' + @entite + N'.';
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_livrable WHERE code = @livrable AND produit_etape_6 = 1)
        RETURN N'le livrable ' + @livrable + N' n''est pas produit par la solution ; seuls les comptes annuels, le rapport de l''expert-comptable et le DIP le sont.';
    IF NOT EXISTS (SELECT 1 FROM dbo.v_livrables_dus WHERE entite = @entite AND arrete = @arrete AND livrable = @livrable)
        RETURN N'le livrable ' + @livrable + N' n''est pas dû à l''arrêté ' + @arrete + N'.';
    IF dbo.fn_revue_visee(@entite, @arrete) = 0
        RETURN N'la revue de l''arrêté n''est pas visée.';
    IF (SELECT TOP (1) decision FROM dbo.visa WHERE nature = 'CLOTURE' AND entite = @entite AND arrete = @arrete
        ORDER BY decide_le DESC, id DESC) = 'VISE'
        RETURN N'l''arrêté est validé pour le client ; une nouvelle production suppose sa réouverture.';
    -- le rapport de l'expert-comptable couvre une version produite et non perimee des comptes annuels
    IF @livrable = 'ATTESTATION'
       AND NOT EXISTS (SELECT 1 FROM dbo.demande_document dd
                       WHERE dd.entite = @entite AND dd.arrete = @arrete AND dd.livrable = 'COMPTES_ANNUELS' AND dd.etat = 'PRODUITE'
                         AND dd.version = (SELECT MAX(d.version) FROM dbo.document_produit d
                                           WHERE d.entite = @entite AND d.arrete = @arrete AND d.livrable = 'COMPTES_ANNUELS')
                         AND NOT EXISTS (SELECT 1 FROM dbo.document_produit d
                                         WHERE d.entite = @entite AND d.arrete = @arrete AND d.livrable = 'COMPTES_ANNUELS'
                                           AND d.version = dd.version AND d.perime_le IS NOT NULL))
        RETURN N'les comptes annuels de l''arrêté ne sont pas produits, ou leur dernière version est périmée ; le rapport de l''expert-comptable les couvre.';
    IF @livrable = 'COMPTES_ANNUELS'
    BEGIN
        SELECT @bloquantes = bloquantes, @articles = articles_fautifs FROM dbo.v_annexe_produisible WHERE entite = @entite AND arrete = @arrete;
        IF ISNULL(@bloquantes, 0) > 0
            RETURN CAST(@bloquantes AS NVARCHAR (8)) + N' cellule(s) restent à remplir sur des tableaux au modèle imposé, articles '
                 + ISNULL(@articles, N'') + N'.';
    END;
    RETURN NULL;
END;

GO

