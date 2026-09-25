CREATE   PROCEDURE dbo.pr_ecran_reprendre_acceptation
    @entite VARCHAR (20),
    @motif NVARCHAR (800),
    @par NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        EXEC dbo.pr_reprendre_acceptation @entite, @motif, @par;
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
    
        -- 13/09/2026 : la relance rend le refus VISIBLE. Sans elle le
        -- service repond 200 et le portail affiche un succes.
        THROW;
    END CATCH;
END;

GO

