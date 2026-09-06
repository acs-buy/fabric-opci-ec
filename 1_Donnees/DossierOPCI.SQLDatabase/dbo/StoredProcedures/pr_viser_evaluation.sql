
-- --- E6, E9 : la procedure refaite et renommee ----------------------
CREATE   PROCEDURE dbo.pr_viser_evaluation
    @evaluation_id INT,
    @decision      VARCHAR (8),
    @decide_par    NVARCHAR (200),
    @motif         NVARCHAR (600) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @entite VARCHAR (20), @arrete VARCHAR (20), @etat VARCHAR (10),
            @propose NVARCHAR (200);
    SELECT @entite = entite, @arrete = arrete, @etat = etat,
           @propose = propose_par
    FROM dbo.evaluation_actif WHERE id = @evaluation_id;

    BEGIN TRY
        IF @entite IS NULL
            THROW 50056, 'Visa refuse : cette valeur retenue n''existe pas.', 1;
        IF @etat <> 'PROPOSE'
            THROW 50056, 'Visa refuse : seule une valeur retenue au statut PROPOSE se vise. Une valeur visee ou renvoyee se reprend par une nouvelle proposition.', 1;

        DECLARE @ref VARCHAR (30) = CAST(@evaluation_id AS VARCHAR (30));
        EXEC dbo.pr_garde_visa 'EVALUATION', @ref, @decision, @decide_par, @motif;

        BEGIN TRANSACTION;
        INSERT INTO dbo.visa (nature, objet_ref, entite, arrete, cycle,
                              decision, motif, propose_par, decide_par)
        VALUES ('EVALUATION', @ref, @entite, @arrete, 'VALO',
                @decision, @motif, @propose, @decide_par);

        -- Le motif du proposant est conserve : seul motif_renvoi recoit
        -- celui du chef de mission.
        UPDATE dbo.evaluation_actif
           SET etat = CASE WHEN @decision = 'VISE' THEN 'VISE' ELSE 'RENVOYE' END,
               vise_par = @decide_par, vise_le = SYSUTCDATETIME(),
               motif_renvoi = CASE WHEN @decision = 'RENVOYE' THEN @motif
                                   ELSE motif_renvoi END
         WHERE id = @evaluation_id;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_viser_evaluation', @entite, @arrete,
                CAST(@evaluation_id AS VARCHAR (30)),
                LEFT(ERROR_MESSAGE(), 2000), @decide_par);
        THROW;
    END CATCH;
END

GO

