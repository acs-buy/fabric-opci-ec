
-- --- 10 : pr_rendre_compte_reevaluation, ce que le pipeline ecrit -----
CREATE   PROCEDURE dbo.pr_rendre_compte_reevaluation
    @demande_id     INT,
    @etat           VARCHAR (12),
    @par            NVARCHAR (200),
    @compte_rendu   NVARCHAR (2000),
    @lot_id         INT = NULL,
    @actifs_traites INT = NULL,
    @actifs_bloques INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @entite VARCHAR (20), @arrete VARCHAR (20), @etat_actuel VARCHAR (12);
    SELECT @entite = entite, @arrete = arrete, @etat_actuel = etat
    FROM dbo.demande_reevaluation WHERE id = @demande_id;
    BEGIN TRY
        IF @entite IS NULL
            THROW 50062, 'Compte rendu refuse : cette demande n''existe pas.', 1;
        IF @etat_actuel <> 'EN_ATTENTE'
            THROW 50062, 'Compte rendu refuse : cette demande a deja recu son compte rendu. Une demande servie ne se sert pas 2 fois.', 1;
        IF @etat NOT IN ('FAITE', 'REFUSEE')
            THROW 50062, 'Compte rendu refuse : l''etat rendu se dit FAITE ou REFUSEE.', 1;

        UPDATE dbo.demande_reevaluation
           SET etat = @etat, lot_id = @lot_id, compte_rendu = @compte_rendu,
               actifs_traites = @actifs_traites, actifs_bloques = @actifs_bloques,
               servie_le = SYSUTCDATETIME(), servie_par = @par
         WHERE id = @demande_id;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, message, refuse_pour)
        VALUES ('pr_rendre_compte_reevaluation', @entite, @arrete,
                LEFT(ERROR_MESSAGE(), 2000), @par);
        THROW;
    END CATCH;
END

GO

