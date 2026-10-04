
CREATE   PROCEDURE dbo.pr_demander_document
    @entite   VARCHAR (20),
    @arrete   VARCHAR (20),
    @livrable VARCHAR (20),
    @par      NVARCHAR (400) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @qui NVARCHAR (400) = ISNULL(@par, SUSER_SNAME());
    DECLARE @version INT = ISNULL((SELECT MAX(version) FROM dbo.demande_document
                                   WHERE entite = @entite AND arrete = @arrete AND livrable = @livrable), 0) + 1;
    DECLARE @motif NVARCHAR (2000) = dbo.fn_obstacle_production(@entite, @arrete, @livrable, @qui);
    IF @motif IS NOT NULL
        SET @motif = N'Production refusée : ' + @motif;

    INSERT INTO dbo.demande_document (entite, arrete, livrable, version, demande_par, etat, motif_refus)
    VALUES (@entite, @arrete, @livrable, @version, @qui, CASE WHEN @motif IS NULL THEN 'DEMANDEE' ELSE 'REFUSEE' END, @motif);

    SELECT SCOPE_IDENTITY() AS demande_id, @version AS version,
           CASE WHEN @motif IS NULL THEN 'DEMANDEE' ELSE 'REFUSEE' END AS etat,
           ISNULL(@motif, N'la demande est enregistrée : la fonction de production peut écrire le document') AS lecture;
END;

GO

