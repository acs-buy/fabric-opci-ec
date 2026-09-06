CREATE   PROCEDURE dbo.pr_ecran_rouvrir_arrete
    @entite VARCHAR (20),
    @arrete VARCHAR (20),
    @motif NVARCHAR (600),
    @par NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        EXEC dbo.pr_rouvrir_arrete @entite, @arrete, @motif, @par;
        UPDATE dbo.ref_arrete
           SET message_ecran = NULL, message_ecran_le = NULL,
               message_ecran_pour = NULL
         WHERE entite = @entite AND arrete = @arrete;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        UPDATE dbo.ref_arrete
           SET message_ecran      = LEFT(ERROR_MESSAGE(), 2000),
               message_ecran_le   = SYSUTCDATETIME(),
               message_ecran_pour = LEFT(@par, 200)
         WHERE entite = @entite AND arrete = @arrete;
    END CATCH;
END;

GO

