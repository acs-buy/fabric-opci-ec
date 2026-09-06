CREATE   PROCEDURE dbo.pr_ecran_annuler_lot
    @lot_id INT,
    @par NVARCHAR (200),
    @motif NVARCHAR (600)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        EXEC dbo.pr_annuler_lot @lot_id, @par, @motif;
        UPDATE dbo.lot_ecritures
           SET message_ecran = NULL, message_ecran_le = NULL,
               message_ecran_pour = NULL
         WHERE id = @lot_id;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        UPDATE dbo.lot_ecritures
           SET message_ecran      = LEFT(ERROR_MESSAGE(), 2000),
               message_ecran_le   = SYSUTCDATETIME(),
               message_ecran_pour = LEFT(@par, 200)
         WHERE id = @lot_id;
    END CATCH;
END;

GO

