CREATE   PROCEDURE dbo.pr_ecran_viser_synthese
    @entite VARCHAR (20),
    @arrete VARCHAR (20),
    @decision VARCHAR (10),
    @motif NVARCHAR (800) = NULL,
    @par NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        EXEC dbo.pr_viser_synthese @entite, @arrete, @decision, @motif, @par;
        UPDATE dbo.synthese_proposee
           SET message_ecran = NULL, message_ecran_le = NULL,
               message_ecran_pour = NULL
         WHERE id = (SELECT TOP 1 id FROM dbo.synthese_proposee
                    WHERE entite = @entite AND arrete = @arrete
                      AND perime_le IS NULL ORDER BY propose_le DESC);
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        UPDATE dbo.synthese_proposee
           SET message_ecran      = LEFT(ERROR_MESSAGE(), 2000),
               message_ecran_le   = SYSUTCDATETIME(),
               message_ecran_pour = LEFT(@par, 200)
         WHERE id = (SELECT TOP 1 id FROM dbo.synthese_proposee
                    WHERE entite = @entite AND arrete = @arrete
                      AND perime_le IS NULL ORDER BY propose_le DESC);
    
        -- 13/09/2026 : la relance rend le refus VISIBLE. Sans elle le
        -- service repond 200 et le portail affiche un succes.
        THROW;
    END CATCH;
END;

GO

