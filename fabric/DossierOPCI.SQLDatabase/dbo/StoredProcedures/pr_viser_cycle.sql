
CREATE   PROCEDURE dbo.pr_viser_cycle
    @entite      VARCHAR (20),
    @arrete      VARCHAR (20),
    @cycle       VARCHAR (10),
    @decision    VARCHAR (8),
    @decide_par  NVARCHAR (400),
    @motif       NVARCHAR (600) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @propose NVARCHAR (400) = (SELECT conclu_par FROM dbo.conclusion_cycle WHERE entite = @entite AND arrete = @arrete AND cycle = @cycle);
    IF @propose IS NULL
        THROW 50331, N'Visa refusé : ce cycle ne porte pas de conclusion. Le conclure avant de le viser.', 1;
    IF @propose = @decide_par
        THROW 50332, N'Visa refusé : le décideur est celui qui a conclu le cycle. Nul ne vise son propre travail.', 1;
    IF dbo.fn_peut_viser_nature(@entite, @decide_par, 'CYCLE', CAST(SYSUTCDATETIME() AS DATE)) = 0
        THROW 50333, N'Visa refusé : cette personne n''a pas, sur cette entité, le rôle que le visa d''un cycle exige, chef de mission.', 1;
    DECLARE @ref VARCHAR (30) = LEFT(@entite + '|' + @cycle, 30);
    EXEC dbo.pr_garde_visa 'CYCLE', @ref, @decision, @decide_par, @motif;
    INSERT INTO dbo.visa (nature, objet_ref, entite, arrete, cycle, decision, motif, propose_par, decide_par)
    VALUES ('CYCLE', @entite + '|' + @arrete + '|' + @cycle, @entite, @arrete, @cycle, @decision, @motif, @propose, @decide_par);
    SELECT @cycle AS cycle, @decision AS decision,
           CASE WHEN @decision = 'VISE' THEN N'Cycle ' + @cycle + N' visé.' ELSE N'Cycle ' + @cycle + N' renvoyé : ' + @motif END AS message;
END;

GO

