
-- --- 6 : pr_viser_derogation -----------------------------------------
CREATE   PROCEDURE dbo.pr_viser_derogation
    @derogation_id INT,
    @decision      VARCHAR (8),
    @decide_par    NVARCHAR (200),
    @motif         NVARCHAR (600) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @entite VARCHAR (20), @arrete VARCHAR (20), @cote VARCHAR (30),
            @cycle VARCHAR (10), @levee DATETIME2 (3), @propose NVARCHAR (200);
    SELECT @entite = d.entite, @arrete = d.arrete, @cote = d.cote,
           @levee = d.levee_le, @propose = d.accordee_par,
           @cycle = (SELECT f.cycle FROM dbo.feuille_travail f
                     WHERE f.cote = d.cote)
    FROM dbo.derogation d WHERE d.id = @derogation_id;

    BEGIN TRY
        IF @entite IS NULL
            THROW 50055, 'Visa refuse : cette derogation n''existe pas.', 1;
        IF @levee IS NOT NULL
            THROW 50055, 'Visa refuse : cette derogation est deja levee. Une derogation levee ne se vise plus.', 1;

        DECLARE @ref VARCHAR (30) = CAST(@derogation_id AS VARCHAR (30));
        EXEC dbo.pr_garde_visa 'DEROGATION', @ref, @decision, @decide_par, @motif;

        BEGIN TRANSACTION;
        INSERT INTO dbo.visa (nature, objet_ref, entite, arrete, cycle,
                              decision, motif, propose_par, decide_par)
        VALUES ('DEROGATION', CAST(@derogation_id AS VARCHAR (30)), @entite,
                @arrete, @cycle, @decision, @motif, @propose, @decide_par);
        -- Un renvoi leve la derogation : la regle a laquelle elle
        -- derogeait redevient opposable.
        UPDATE dbo.derogation
           SET levee_par = @decide_par, levee_le = SYSUTCDATETIME()
         WHERE id = @derogation_id AND @decision = 'RENVOYE';
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_viser_derogation', @entite, @arrete,
                CAST(@derogation_id AS VARCHAR (30)),
                LEFT(ERROR_MESSAGE(), 2000), @decide_par);
        THROW;
    END CATCH;
END

GO

