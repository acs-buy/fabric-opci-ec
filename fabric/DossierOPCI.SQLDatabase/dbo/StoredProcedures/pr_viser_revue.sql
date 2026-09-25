
CREATE   PROCEDURE dbo.pr_viser_revue
    @entite      VARCHAR (20),
    @arrete      VARCHAR (20),
    @decision    VARCHAR (8),
    @decide_par  NVARCHAR (400),
    @motif       NVARCHAR (600) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @propose NVARCHAR (400) = (SELECT conclu_par FROM dbo.conclusion_revue WHERE entite = @entite AND arrete = @arrete);
    IF @propose IS NULL
        THROW 50341, N'Visa refusé : la revue ne porte pas de conclusion générale. La conclure avant de la viser.', 1;
    IF @propose = @decide_par
        THROW 50342, N'Visa refusé : le décideur est celui qui a conclu la revue. Nul ne vise son propre travail.', 1;
    IF dbo.fn_peut_viser_nature(@entite, @decide_par, 'REVUE', CAST(SYSUTCDATETIME() AS DATE)) = 0
        THROW 50343, N'Visa refusé : cette personne n''a pas, sur cette entité, le rôle que le visa de la revue exige, chef de mission.', 1;
    -- tous les cycles du programme doivent etre vises avant la revue
    DECLARE @non_vises NVARCHAR (400) =
        (SELECT STRING_AGG(CAST(c.code AS NVARCHAR (10)), N', ') FROM dbo.ref_cycle c
         WHERE EXISTS (SELECT 1 FROM dbo.programme_travail p JOIN dbo.programme_question pq ON pq.programme_id = p.id AND pq.actif = 1
                       JOIN dbo.ref_question q ON q.id = pq.question_id WHERE p.entite = @entite AND p.arrete = @arrete AND q.cycle = c.code)
           AND NOT EXISTS (SELECT 1 FROM dbo.visa v WHERE v.nature = 'CYCLE' AND v.entite = @entite AND v.arrete = @arrete AND v.cycle = c.code AND v.decision = 'VISE'));
    IF @decision = 'VISE' AND @non_vises IS NOT NULL
    BEGIN
        DECLARE @m NVARCHAR (800) = N'Visa refusé : des cycles du programme ne sont pas visés : ' + @non_vises + N'. La revue se vise après ses cycles.';
        THROW 50344, @m, 1;
    END;
    DECLARE @ref VARCHAR (30) = LEFT(@entite + '|' + @arrete, 30);
    EXEC dbo.pr_garde_visa 'REVUE', @ref, @decision, @decide_par, @motif;
    BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO dbo.visa (nature, objet_ref, entite, arrete, cycle, decision, motif, propose_par, decide_par)
    VALUES ('REVUE', @entite + '|' + @arrete, @entite, @arrete, NULL, @decision, @motif, @propose, @decide_par);
    IF @decision = 'VISE'
    BEGIN
        IF EXISTS (SELECT 1 FROM dbo.dossier_verrou WHERE entite = @entite AND arrete = @arrete)
            UPDATE dbo.dossier_verrou SET verrouille = 1, verrouille_par = @decide_par, verrouille_le = SYSUTCDATETIME(),
                                          deverrouille_par = NULL, deverrouille_le = NULL
             WHERE entite = @entite AND arrete = @arrete;
        ELSE
            INSERT INTO dbo.dossier_verrou (entite, arrete, verrouille, verrouille_par) VALUES (@entite, @arrete, 1, @decide_par);
    END;
    COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
    SELECT @decision AS decision,
           CASE WHEN @decision = 'VISE' THEN N'Revue visée : le dossier de travail de l''arrêté ' + @arrete + N' est verrouillé. Il s''exporte, il ne se réimporte plus.'
                ELSE N'Revue renvoyée : ' + @motif END AS message;
END;

GO

