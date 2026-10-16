
CREATE   PROCEDURE dbo.pr_ecran_proposer_valeur_retenue
    @vehicule   VARCHAR (20),
    @arrete     VARCHAR (20),
    @code_actif VARCHAR (20),
    @valeur     DECIMAL (19,2),
    @source     NVARCHAR (60),
    @motif      NVARCHAR (600) = NULL,
    @piece_id   INT = NULL,
    @par        NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @r NVARCHAR (1000) = COALESCE(dbo.fn_e3_refus_commun(@vehicule, @arrete, @par),
                                          dbo.fn_e3_refus_valeur(@vehicule, @arrete, @code_actif, @valeur, @source, @motif, @piece_id));
    IF @r IS NOT NULL EXEC dbo.pr_e3_refuser @r;
    DECLARE @tc INT = @@TRANCOUNT, @resultat VARCHAR (10),
            @detentrice VARCHAR (20) = (SELECT entite_detentrice FROM dbo.actif WHERE code = @code_actif);
    BEGIN TRY
        BEGIN TRANSACTION;
        EXEC dbo.pr_e3_verrouiller @entite = @detentrice;
        EXEC dbo.pr_e3_ecrire_valeur @arrete, @code_actif, @valeur, @source, @motif, @piece_id, @par, @resultat OUTPUT;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @tc = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
    SELECT @vehicule AS vehicule,
           N'Valeur retenue de ' + @code_actif + N' ' + CASE @resultat WHEN 'REPRISE' THEN N'reprise' ELSE N'proposée' END
           + N' : ' + dbo.fn_e3_montant(@valeur) + N', source ' + (SELECT libelle FROM dbo.ref_source_valeur WHERE source = dbo.fn_e3_source_saisie(@source))
           + N'. Elle attend le visa du chef de mission.' AS message;
END;

GO

