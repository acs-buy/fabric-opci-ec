
-- --- 4 : pr_viser_lot ------------------------------------------------
-- Le patron des 4 procedures : elle resout le proposant, ecrit le visa,
-- porte la decision sur l'objet, et journalise tout refus.
CREATE   PROCEDURE dbo.pr_viser_lot
    @lot_id     INT,
    @decision   VARCHAR (8),
    @decide_par NVARCHAR (200),
    @motif      NVARCHAR (600) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @entite VARCHAR (20), @arrete VARCHAR (20), @cycle VARCHAR (10),
            @statut VARCHAR (20), @propose NVARCHAR (200);
    SELECT @entite = l.entite, @arrete = l.arrete, @statut = l.statut,
           @propose = l.cree_par,
           @cycle = (SELECT f.cycle FROM dbo.feuille_travail f
                     WHERE f.cote = l.feuille_cote)
    FROM dbo.lot_ecritures l WHERE l.id = @lot_id;

    BEGIN TRY
        IF @entite IS NULL
            THROW 50053, 'Visa refuse : ce lot n''existe pas.', 1;
        IF @statut <> 'PROPOSE'
            THROW 50053, 'Visa refuse : seul un lot au statut PROPOSE se vise. Un lot deja valide, rejete, exporte ou publie ne se revise pas, il se corrige par un lot d''annulation.', 1;

        DECLARE @ref VARCHAR (30) = CAST(@lot_id AS VARCHAR (30));
        EXEC dbo.pr_garde_visa 'LOT', @ref, @decision, @decide_par, @motif;

        BEGIN TRANSACTION;
        INSERT INTO dbo.visa (nature, objet_ref, entite, arrete, cycle,
                              decision, motif, propose_par, decide_par)
        VALUES ('LOT', CAST(@lot_id AS VARCHAR (30)), @entite, @arrete, @cycle,
                @decision, @motif, @propose, @decide_par);

        UPDATE dbo.lot_ecritures
           SET statut = CASE WHEN @decision = 'VISE' THEN 'VALIDE'
                             ELSE 'REJETE' END,
               statut_par = @decide_par, statut_le = SYSUTCDATETIME(),
               motif = COALESCE(@motif, motif)
         WHERE id = @lot_id;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_viser_lot', @entite, @arrete,
                CAST(@lot_id AS VARCHAR (30)),
                LEFT(ERROR_MESSAGE(), 2000), @decide_par);
        THROW;
    END CATCH;
END

GO

