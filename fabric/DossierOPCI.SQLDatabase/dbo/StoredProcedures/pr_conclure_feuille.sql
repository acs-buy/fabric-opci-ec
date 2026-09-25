
-- --- 4 : conclure une feuille, geste au bouton --------------------------
CREATE   PROCEDURE dbo.pr_conclure_feuille
    @cote  VARCHAR (30),
    @forme VARCHAR (20),
    @par   NVARCHAR (200)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @entite VARCHAR (20), @arrete VARCHAR (20);
    SELECT @entite = entite, @arrete = arrete
    FROM dbo.feuille_travail WHERE cote = @cote;
    BEGIN TRY
        UPDATE dbo.feuille_travail
        SET forme_conclusion = @forme,
            conclue_par = @par,
            conclue_le = SYSUTCDATETIME()
        WHERE cote = @cote;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_conclure_feuille', @entite, @arrete, @cote,
                LEFT(ERROR_MESSAGE(), 2000), @par);
        THROW;
    END CATCH;
END;

GO

