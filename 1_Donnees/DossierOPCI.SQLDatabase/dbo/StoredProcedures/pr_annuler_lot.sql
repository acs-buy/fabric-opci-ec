
-- --- 11 : pr_annuler_lot ---------------------------------------------
-- Promise par la specification et absente jusqu'ici. Elle annule un lot
-- PROPOSE, jamais un lot vise : un lot valide se corrige par un lot
-- d'annulation qui porte ses propres ecritures, non par un effacement.
CREATE   PROCEDURE dbo.pr_annuler_lot
    @lot_id INT,
    @par    NVARCHAR (200),
    @motif  NVARCHAR (600)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @entite VARCHAR (20), @arrete VARCHAR (20), @statut VARCHAR (20);
    SELECT @entite = entite, @arrete = arrete, @statut = statut
    FROM dbo.lot_ecritures WHERE id = @lot_id;
    BEGIN TRY
        IF @entite IS NULL
            THROW 50063, 'Annulation refusee : ce lot n''existe pas.', 1;
        IF @statut <> 'PROPOSE'
            THROW 50063, 'Annulation refusee : seul un lot PROPOSE s''annule. Un lot valide, exporte ou publie se corrige par un lot d''annulation portant ses propres ecritures, jamais par un effacement.', 1;
        IF @motif IS NULL
            THROW 50063, 'Annulation refusee : l''annulation porte son motif.', 1;

        BEGIN TRANSACTION;
        -- Le lot passe a REJETE et garde ses ecritures : l'annulation est
        -- une decision tracee, non une disparition.
        UPDATE dbo.lot_ecritures
           SET statut = 'REJETE', statut_par = @par, statut_le = SYSUTCDATETIME(),
               motif = @motif
         WHERE id = @lot_id;
        -- La demande qui l'a produit repasse en attente d'une nouvelle,
        -- son lot n'existant plus au sens de la valorisation.
        UPDATE dbo.demande_reevaluation
           SET etat = 'ANNULEE', lot_id = NULL,
               compte_rendu = COALESCE(compte_rendu, N'')
               + N' | Lot annule le ' + CONVERT(VARCHAR (19), SYSUTCDATETIME(), 120)
               + N' : ' + @motif,
               servie_le = COALESCE(servie_le, SYSUTCDATETIME()),
               servie_par = COALESCE(servie_par, @par)
         WHERE lot_id = @lot_id;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_annuler_lot', @entite, @arrete,
                CAST(@lot_id AS VARCHAR (30)),
                LEFT(ERROR_MESSAGE(), 2000), @par);
        THROW;
    END CATCH;
END

GO

