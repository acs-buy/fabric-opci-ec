

-- 7. VISER OU RENVOYER UN CYCLE. VISE : le premier obstacle de fn_obstacle_visa_cycle, puis
-- l'auteur et le role. RENVOYE : admis depuis CONCLU et VISE (§ 7, point 8), jamais sur dossier verrouille ni
-- revue visee ; il n'est pas soumis a E1, il peut porter sur ce qui manque.
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
    DECLARE @etat VARCHAR (12) = dbo.fn_etat_cycle(@entite, @arrete, @cycle), @o NVARCHAR (2000), @num INT, @m NVARCHAR (2000);
    IF @decision = 'VISE'
    BEGIN
        SET @o = dbo.fn_obstacle_visa_cycle(@entite, @arrete, @cycle);
        IF @o IS NOT NULL
        BEGIN
            SELECT @num = CAST(LEFT(@o, 5) AS INT), @m = SUBSTRING(@o, 7, 2000);
            THROW @num, @m, 1;
        END;
    END
    ELSE IF @decision = 'RENVOYE'
    BEGIN
        IF @etat = 'A_CONCLURE'
            THROW 50331, N'Visa refusé : ce cycle ne porte pas de conclusion. Le conclure avant de le viser.', 1;
        IF @etat = 'RENVOYE'
            THROW 50507, N'Renvoi refusé : ce cycle est déjà renvoyé, et sa conclusion n''a pas été reprise.', 1;
        IF dbo.fn_dossier_verrouille(@entite, @arrete) = 1
            THROW 50508, N'Décision refusée : le dossier de cet arrêté est visé et verrouillé.', 1;
        IF dbo.fn_revue_visee(@entite, @arrete) = 1
            THROW 50509, N'Refusé : la revue de cet arrêté est visée ; déverrouiller le dossier avant de rouvrir un cycle.', 1;
    END;
    DECLARE @propose NVARCHAR (400) = (SELECT conclu_par FROM dbo.conclusion_cycle WHERE entite = @entite AND arrete = @arrete AND cycle = @cycle);
    IF @propose = @decide_par
        THROW 50332, N'Visa refusé : le décideur est celui qui a conclu le cycle. Nul ne vise son propre travail.', 1;
    IF dbo.fn_peut_viser_nature(@entite, @decide_par, 'CYCLE', CAST(SYSUTCDATETIME() AS DATE)) = 0
        THROW 50333, N'Visa refusé : cette personne n''a pas, sur cette entité, le rôle que le visa d''un cycle exige, chef de mission.', 1;
    DECLARE @ref VARCHAR (60) = @entite + '|' + @arrete + '|' + @cycle;
    EXEC dbo.pr_garde_visa 'CYCLE', @ref, @decision, @decide_par, @motif;
    INSERT INTO dbo.visa (nature, objet_ref, entite, arrete, cycle, decision, motif, propose_par, decide_par)
    VALUES ('CYCLE', @ref, @entite, @arrete, @cycle, @decision, @motif, @propose, @decide_par);
    SELECT @cycle AS cycle, @decision AS decision,
           CASE WHEN @decision = 'VISE' THEN N'Cycle ' + @cycle + N' visé.' ELSE N'Cycle ' + @cycle + N' renvoyé : ' + @motif END AS message;
END;

GO

