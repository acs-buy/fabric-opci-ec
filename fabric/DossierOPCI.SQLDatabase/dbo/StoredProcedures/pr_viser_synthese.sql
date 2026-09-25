
CREATE   PROCEDURE dbo.pr_viser_synthese
    @entite VARCHAR (20),
    @arrete VARCHAR (20),
    @decision VARCHAR (10),
    @motif  NVARCHAR (800) = NULL,
    @par    NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @s INT, @propose NVARCHAR (400);
    SELECT TOP 1 @s = id, @propose = propose_par FROM dbo.synthese_proposee
    WHERE entite = @entite AND arrete = @arrete AND perime_le IS NULL
    ORDER BY propose_le DESC;

    IF @s IS NULL
        THROW 50081,
            N'Visa refusé : aucune synthèse en cours n''est proposée pour cet arrêté, ou celle qui l''était est périmée par le visa d''un lot postérieur. Proposer la synthèse de nouveau.',
            1;

    DECLARE @ref VARCHAR (30) = @entite + '|' + @arrete;
    EXEC dbo.pr_garde_visa 'SYNTHESE', @ref, @decision, @par, @motif;

    INSERT INTO dbo.visa (nature, objet_ref, entite, arrete, cycle,
                          decision, motif, propose_par, decide_par, decide_le)
    VALUES ('SYNTHESE', @ref, @entite, @arrete, NULL, @decision, @motif,
            @propose, @par, SYSUTCDATETIME());
END;

GO

