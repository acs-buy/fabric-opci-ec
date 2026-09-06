CREATE   PROCEDURE dbo.pr_ecran_viser_evaluation
    @evaluation_id INT,
    @decision VARCHAR (8),
    @decide_par NVARCHAR (200),
    @motif NVARCHAR (600) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        EXEC dbo.pr_viser_evaluation @evaluation_id, @decision, @decide_par, @motif;
        UPDATE dbo.evaluation_actif
           SET message_ecran = NULL, message_ecran_le = NULL,
               message_ecran_pour = NULL
         WHERE id = @evaluation_id;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        UPDATE dbo.evaluation_actif
           SET message_ecran      = LEFT(ERROR_MESSAGE(), 2000),
               message_ecran_le   = SYSUTCDATETIME(),
               message_ecran_pour = LEFT(@decide_par, 200)
         WHERE id = @evaluation_id;
    END CATCH;
END;

GO

