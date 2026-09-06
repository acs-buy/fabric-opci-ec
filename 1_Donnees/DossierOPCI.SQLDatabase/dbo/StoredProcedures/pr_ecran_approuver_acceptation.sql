CREATE   PROCEDURE dbo.pr_ecran_approuver_acceptation
    @entite VARCHAR (20),
    @decision VARCHAR (10),
    @motif NVARCHAR (800) = NULL,
    @par NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        EXEC dbo.pr_approuver_acceptation @entite, @decision, @motif, @par;
        UPDATE dbo.acceptation_mission
           SET message_ecran = NULL, message_ecran_le = NULL,
               message_ecran_pour = NULL
         WHERE id = (SELECT TOP 1 id FROM dbo.acceptation_mission
                    WHERE entite = @entite ORDER BY cree_le DESC);
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        UPDATE dbo.acceptation_mission
           SET message_ecran      = LEFT(ERROR_MESSAGE(), 2000),
               message_ecran_le   = SYSUTCDATETIME(),
               message_ecran_pour = LEFT(@par, 200)
         WHERE id = (SELECT TOP 1 id FROM dbo.acceptation_mission
                    WHERE entite = @entite ORDER BY cree_le DESC);
    END CATCH;
END;

GO

