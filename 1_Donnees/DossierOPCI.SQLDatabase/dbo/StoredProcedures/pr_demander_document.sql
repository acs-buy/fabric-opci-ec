
-- --- 4 : O28, la procedure appelee par le bouton ---------------------
-- ELLE REFUSE SANS RIEN ECRIRE D'AUTRE QUE LE REFUS. Une demande
-- refusee laisse une ligne a l'etat REFUSEE avec son motif : l'ecran la
-- lit, et le dossier garde trace de la tentative.
CREATE   PROCEDURE dbo.pr_demander_document
    @entite   VARCHAR (20),
    @arrete   VARCHAR (20),
    @livrable VARCHAR (20),
    @par      NVARCHAR (400) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @qui NVARCHAR (400) = ISNULL(@par, SUSER_SNAME());
    DECLARE @version INT =
        ISNULL((SELECT MAX(version) FROM dbo.demande_document
                WHERE entite = @entite AND arrete = @arrete
                  AND livrable = @livrable), 0) + 1;
    DECLARE @motif NVARCHAR (2000) = NULL;

    -- Le livrable existe et s'applique.
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_livrable WHERE code = @livrable)
        SET @motif = N'Livrable inconnu : ' + @livrable + N'.';

    -- L'arrete existe.
    IF @motif IS NULL
       AND NOT EXISTS (SELECT 1 FROM dbo.ref_arrete
                       WHERE entite = @entite AND arrete = @arrete)
        SET @motif = N'Arrêté inconnu pour cette entité.';

    -- LE ROLE. Produire un document du dossier suppose d'y tenir un
    -- role, quel qu'il soit : la production n'est pas un visa, elle est
    -- un geste de travail.
    IF @motif IS NULL
       AND NOT EXISTS (SELECT 1 FROM dbo.role_mission r
                       WHERE r.entite = @entite
                         AND r.connexion = SUSER_SNAME()
                         AND r.du <= CAST(SYSUTCDATETIME() AS DATE)
                         AND (r.au IS NULL
                              OR r.au > CAST(SYSUTCDATETIME() AS DATE)))
        SET @motif = N'Votre compte ne tient aucun rôle sur cette entité : demander à l''associé de vous en attribuer un.';

    -- LES CELLULES A REMPLIR, sur les seuls tableaux au modele impose.
    IF @motif IS NULL
    BEGIN
        DECLARE @bloquantes INT, @articles NVARCHAR (1000);
        SELECT @bloquantes = bloquantes, @articles = articles_fautifs
        FROM dbo.v_annexe_produisible
        WHERE entite = @entite AND arrete = @arrete;

        IF ISNULL(@bloquantes, 0) > 0
            SET @motif = N'Production refusée : '
                       + CAST(@bloquantes AS NVARCHAR (8))
                       + N' cellule(s) restent à remplir sur des tableaux au modèle imposé, articles '
                       + ISNULL(@articles, N'') + N'.';
    END;

    INSERT INTO dbo.demande_document
        (entite, arrete, livrable, version, demande_par, etat, motif_refus)
    VALUES (@entite, @arrete, @livrable, @version, @qui,
            CASE WHEN @motif IS NULL THEN 'DEMANDEE' ELSE 'REFUSEE' END,
            @motif);

    SELECT SCOPE_IDENTITY() AS demande_id, @version AS version,
           CASE WHEN @motif IS NULL THEN 'DEMANDEE' ELSE 'REFUSEE' END AS etat,
           ISNULL(@motif, N'la demande est enregistrée : la fonction de production peut écrire le document')
                                                        AS lecture;
END;

GO

