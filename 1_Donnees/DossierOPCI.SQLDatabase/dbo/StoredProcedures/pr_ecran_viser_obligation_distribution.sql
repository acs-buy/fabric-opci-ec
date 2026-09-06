CREATE   PROCEDURE dbo.pr_ecran_viser_obligation_distribution
    @entite VARCHAR (20),
    @exercice VARCHAR (20),
    @categorie VARCHAR (20),
    @base_calcul DECIMAL (19,2),
    @taux DECIMAL (9,6),
    @source NVARCHAR (400),
    @vise_par NVARCHAR (200)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        EXEC dbo.pr_viser_obligation_distribution @entite, @exercice, @categorie, @base_calcul, @taux, @source, @vise_par;
        UPDATE dbo.obligation_distribution
           SET message_ecran = NULL, message_ecran_le = NULL,
               message_ecran_pour = NULL
         WHERE id = (SELECT TOP 1 id FROM dbo.obligation_distribution
                    WHERE entite = @entite AND exercice = @exercice
                      AND categorie = @categorie ORDER BY id DESC);
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        UPDATE dbo.obligation_distribution
           SET message_ecran      = LEFT(ERROR_MESSAGE(), 2000),
               message_ecran_le   = SYSUTCDATETIME(),
               message_ecran_pour = LEFT(@vise_par, 200)
         WHERE id = (SELECT TOP 1 id FROM dbo.obligation_distribution
                    WHERE entite = @entite AND exercice = @exercice
                      AND categorie = @categorie ORDER BY id DESC);
    END CATCH;
END;

GO

