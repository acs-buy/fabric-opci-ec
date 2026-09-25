
-- --- 5 : pr_viser_conclusion -----------------------------------------
CREATE   PROCEDURE dbo.pr_viser_conclusion
    @cote       VARCHAR (30),
    @decision   VARCHAR (8),
    @decide_par NVARCHAR (200),
    @motif      NVARCHAR (600) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @entite VARCHAR (20), @arrete VARCHAR (20), @cycle VARCHAR (10),
            @forme VARCHAR (20), @propose NVARCHAR (200);
    SELECT @entite = entite, @arrete = arrete, @cycle = cycle,
           @forme = forme_conclusion, @propose = preparateur
    FROM dbo.feuille_travail WHERE cote = @cote;

    BEGIN TRY
        IF @entite IS NULL
            THROW 50054, 'Visa refuse : cette feuille de travail n''existe pas.', 1;
        IF @forme IS NULL
            THROW 50054, 'Visa refuse : la feuille ne porte aucune conclusion. Une feuille se conclut par dbo.pr_conclure_feuille avant de se viser.', 1;

        DECLARE @ref VARCHAR (30) = @cote;
        EXEC dbo.pr_garde_visa 'CONCLUSION', @ref, @decision, @decide_par, @motif;

        BEGIN TRANSACTION;
        INSERT INTO dbo.visa (nature, objet_ref, entite, arrete, cycle,
                              decision, motif, propose_par, decide_par)
        VALUES ('CONCLUSION', @cote, @entite, @arrete, @cycle,
                @decision, @motif, @propose, @decide_par);
        -- Le reviseur de la feuille est le decideur du visa : la colonne
        -- existait deja et porte desormais la trace du visa.
        UPDATE dbo.feuille_travail
           SET reviseur = @decide_par, revise_le = SYSUTCDATETIME()
         WHERE cote = @cote AND @decision = 'VISE';
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_viser_conclusion', @entite, @arrete, @cote,
                LEFT(ERROR_MESSAGE(), 2000), @decide_par);
        THROW;
    END CATCH;
END

GO

