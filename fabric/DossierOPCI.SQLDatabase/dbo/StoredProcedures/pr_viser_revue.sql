

-- 9. VISER OU RENVOYER LA REVUE. VISE : le premier obstacle de fn_obstacle_visa_revue, puis
-- l'auteur et le role. RENVOYE : depuis CONCLUE seulement ; depuis VISEE, le dossier est verrouille et le seul
-- renvoi est le deverrouillage. Le visa pose le verrou et ne remet plus a NULL le dernier deverrouillage.
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
    DECLARE @etat VARCHAR (12) = dbo.fn_etat_revue(@entite, @arrete), @o NVARCHAR (2000), @num INT, @m NVARCHAR (2000);
    IF @decision = 'VISE'
    BEGIN
        SET @o = dbo.fn_obstacle_visa_revue(@entite, @arrete);
        IF @o IS NOT NULL
        BEGIN
            SELECT @num = CAST(LEFT(@o, 5) AS INT), @m = SUBSTRING(@o, 7, 2000);
            THROW @num, @m, 1;
        END;
    END
    ELSE IF @decision = 'RENVOYE'
    BEGIN
        IF @etat = 'A_CONCLURE'
            THROW 50341, N'Visa refusé : la revue ne porte pas de conclusion générale. La conclure avant de la viser.', 1;
        IF @etat = 'RENVOYEE'
            THROW 50513, N'Renvoi refusé : la revue est déjà renvoyée, et sa conclusion n''a pas été reprise.', 1;
        IF @etat = 'VISEE' OR dbo.fn_dossier_verrouille(@entite, @arrete) = 1
            THROW 50514, N'Décision refusée : le dossier de cet arrêté est visé et verrouillé ; le déverrouiller d''abord.', 1;
    END;
    DECLARE @propose NVARCHAR (400) = (SELECT conclu_par FROM dbo.conclusion_revue WHERE entite = @entite AND arrete = @arrete);
    IF @propose = @decide_par
        THROW 50342, N'Visa refusé : le décideur est celui qui a conclu la revue. Nul ne vise son propre travail.', 1;
    IF dbo.fn_peut_viser_nature(@entite, @decide_par, 'REVUE', CAST(SYSUTCDATETIME() AS DATE)) = 0
        THROW 50343, N'Visa refusé : cette personne n''a pas, sur cette entité, le rôle que le visa de la revue exige, chef de mission.', 1;
    DECLARE @ref VARCHAR (60) = @entite + '|' + @arrete;
    EXEC dbo.pr_garde_visa 'REVUE', @ref, @decision, @decide_par, @motif;
    BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO dbo.visa (nature, objet_ref, entite, arrete, cycle, decision, motif, propose_par, decide_par)
    VALUES ('REVUE', @ref, @entite, @arrete, NULL, @decision, @motif, @propose, @decide_par);
    IF @decision = 'VISE'
    BEGIN
        IF EXISTS (SELECT 1 FROM dbo.dossier_verrou WHERE entite = @entite AND arrete = @arrete)
            UPDATE dbo.dossier_verrou SET verrouille = 1, verrouille_par = @decide_par, verrouille_le = SYSUTCDATETIME()
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

