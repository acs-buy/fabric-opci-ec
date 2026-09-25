CREATE   PROCEDURE dbo.pr_ecran_viser_derogation
    @derogation_id INT,
    @decision VARCHAR (8),
    @decide_par NVARCHAR (200),
    @motif NVARCHAR (600) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        EXEC dbo.pr_viser_derogation @derogation_id, @decision, @decide_par, @motif;
        UPDATE dbo.derogation
           SET message_ecran = NULL, message_ecran_le = NULL,
               message_ecran_pour = NULL
         WHERE id = @derogation_id;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        UPDATE dbo.derogation
           SET message_ecran      = LEFT(ERROR_MESSAGE(), 2000),
               message_ecran_le   = SYSUTCDATETIME(),
               message_ecran_pour = LEFT(@decide_par, 200)
         WHERE id = @derogation_id;
    
        -- 13/09/2026 : la relance rend le refus VISIBLE. Sans elle le
        -- service repond 200 et le portail affiche un succes.
        THROW;
    END CATCH;
END;

GO

