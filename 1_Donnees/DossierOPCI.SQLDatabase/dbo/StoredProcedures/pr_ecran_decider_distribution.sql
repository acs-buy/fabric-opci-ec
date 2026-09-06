CREATE   PROCEDURE dbo.pr_ecran_decider_distribution
    @entite VARCHAR (20),
    @exercice VARCHAR (20),
    @categorie VARCHAR (30),
    @montant DECIMAL (19,2),
    @assemblee DATE,
    @par NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        EXEC dbo.pr_decider_distribution @entite, @exercice, @categorie, @montant, @assemblee, @par;
        UPDATE dbo.decision_distribution
           SET message_ecran = NULL, message_ecran_le = NULL,
               message_ecran_pour = NULL
         WHERE entite = @entite AND exercice = @exercice AND categorie = @categorie;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        UPDATE dbo.decision_distribution
           SET message_ecran      = LEFT(ERROR_MESSAGE(), 2000),
               message_ecran_le   = SYSUTCDATETIME(),
               message_ecran_pour = LEFT(@par, 200)
         WHERE entite = @entite AND exercice = @exercice AND categorie = @categorie;
    END CATCH;
END;

GO

