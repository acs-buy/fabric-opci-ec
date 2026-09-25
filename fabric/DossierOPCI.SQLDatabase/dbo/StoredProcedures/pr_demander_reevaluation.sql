
-- --- 9 : pr_demander_reevaluation ------------------------------------
CREATE   PROCEDURE dbo.pr_demander_reevaluation
    @entite VARCHAR (20),
    @arrete VARCHAR (20),
    @par    NVARCHAR (200),
    @motif  NVARCHAR (600) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.ref_arrete
                       WHERE entite = @entite AND arrete = @arrete)
            THROW 50061, 'Demande refusee : cet arrete n''existe pas au referentiel.', 1;

        -- K4, premier volet : une demande en attente interdit la seconde.
        IF EXISTS (SELECT 1 FROM dbo.demande_reevaluation
                   WHERE entite = @entite AND arrete = @arrete
                     AND etat = 'EN_ATTENTE')
            THROW 50061, 'Demande refusee : une demande est deja en attente pour cette entite a cet arrete. Attendre son compte rendu, ou l''annuler.', 1;

        -- K4, second volet : un lot propose non perime couvre deja le
        -- perimetre. En generer un second produirait 2 lots concurrents.
        DECLARE @lot_propose INT =
            (SELECT TOP (1) id FROM dbo.lot_ecritures
             WHERE entite = @entite AND arrete = @arrete
               AND statut = 'PROPOSE' AND famille = 'DERIVABLE'
               AND perime_le IS NULL);
        IF @lot_propose IS NOT NULL
        BEGIN
            DECLARE @m NVARCHAR (2000) =
                N'Demande refusee : le lot ' + CAST(@lot_propose AS NVARCHAR (20))
                + N' est propose et non perime pour cette entite a cet arrete. '
                + N'Le viser, le renvoyer ou l''annuler avant de regenerer.';
            THROW 50061, @m, 1;
        END;

        -- K4, troisieme volet : rien de calculable, rien a generer. Les
        -- motifs de blocage se lisent dans dbo.v_a_generer.
        DECLARE @calculables INT =
            (SELECT COUNT(*) FROM dbo.v_a_generer
             WHERE entite = @entite AND arrete = @arrete
               AND etat_generation = 'CALCULABLE');
        IF @calculables = 0
            THROW 50061, 'Demande refusee : aucun actif n''est calculable a cet arrete. Lire dbo.v_a_generer pour le motif de blocage de chacun.', 1;

        INSERT INTO dbo.demande_reevaluation
            (entite, arrete, etat, posee_par, motif_demande)
        VALUES (@entite, @arrete, 'EN_ATTENTE', @par, @motif);
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, message, refuse_pour)
        VALUES ('pr_demander_reevaluation', @entite, @arrete,
                LEFT(ERROR_MESSAGE(), 2000), @par);
        THROW;
    END CATCH;
END

GO

