
CREATE   PROCEDURE dbo.pr_ecran_produire_attestation
    @entite  VARCHAR (20),
    @arrete  VARCHAR (20),
    @fichier NVARCHAR (400),
    @par     NVARCHAR (400),
    @empreinte_stockee CHAR (64) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        EXEC dbo.pr_produire_attestation @entite, @arrete, @fichier, @par, @empreinte_stockee;
        UPDATE dbo.ref_arrete
           SET message_ecran = NULL, message_ecran_le = NULL, message_ecran_pour = NULL
         WHERE entite = @entite AND arrete = @arrete;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        UPDATE dbo.ref_arrete
           SET message_ecran      = LEFT(ERROR_MESSAGE(), 2000),
               message_ecran_le   = SYSUTCDATETIME(),
               message_ecran_pour = LEFT(@par, 200)
         WHERE entite = @entite AND arrete = @arrete;
        -- la relance rend le refus visible : sans elle le service repond 200 et le portail affiche un succes
        THROW;
    END CATCH;
END;

GO

