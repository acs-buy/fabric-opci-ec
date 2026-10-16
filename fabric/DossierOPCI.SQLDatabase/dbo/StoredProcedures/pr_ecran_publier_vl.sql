
CREATE   PROCEDURE dbo.pr_ecran_publier_vl
    @entite VARCHAR (20),
    @arrete VARCHAR (20),
    @par NVARCHAR (200)
AS
BEGIN
    SET NOCOUNT ON;
    -- 15/10/2026 : une personne vide ou NULL se refuse en francais, avant tout le reste
    IF NULLIF(LTRIM(RTRIM(@par)), N'') IS NULL
        THROW 50826, N'Publication refusée : votre compte ne tient pas, sur ce dossier, le rôle d''associé signataire qui publie la valeur liquidative.', 1;
    BEGIN TRY
        EXEC dbo.pr_publier_vl @entite, @arrete, @par;
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
    
        -- 13/09/2026 : la relance rend le refus VISIBLE. Sans elle le
        -- service repond 200 et le portail affiche un succes.
        THROW;
    END CATCH;
END;

GO

