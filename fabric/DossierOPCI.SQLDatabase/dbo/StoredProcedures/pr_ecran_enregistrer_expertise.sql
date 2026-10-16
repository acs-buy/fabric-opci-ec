
CREATE   PROCEDURE dbo.pr_ecran_enregistrer_expertise
    @vehicule   VARCHAR (20),
    @arrete     VARCHAR (20),
    @code_actif VARCHAR (20),
    @valeur     DECIMAL (19,2),
    @piece_id   INT,
    @par        NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @r NVARCHAR (1000) = COALESCE(dbo.fn_e3_refus_commun(@vehicule, @arrete, @par),
                                          dbo.fn_e3_refus_expertise(@vehicule, @arrete, @code_actif, @valeur, @piece_id));
    IF @r IS NOT NULL EXEC dbo.pr_e3_refuser @r;
    DECLARE @tc INT = @@TRANCOUNT, @resultat VARCHAR (10), @ancienne DECIMAL (19,2), @version INT, @rattachee BIT,
            @detentrice VARCHAR (20) = (SELECT entite_detentrice FROM dbo.actif WHERE code = @code_actif);
    BEGIN TRY
        BEGIN TRANSACTION;
        EXEC dbo.pr_e3_verrouiller @entite = @detentrice;
        EXEC dbo.pr_e3_ecrire_expertise @arrete, @code_actif, @valeur, @piece_id, @par,
             @resultat OUTPUT, @ancienne OUTPUT, @version OUTPUT, @rattachee OUTPUT;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @tc = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
    SELECT @vehicule AS vehicule,
           N'Expertise de ' + @code_actif + N' au ' + dbo.fn_date_ecran(@arrete)
           + CASE @resultat WHEN 'INSEREE' THEN N' enregistrée : ' + dbo.fn_e3_montant(@valeur) + N'.'
                            WHEN 'REMPLACEE' THEN N' remplacée : ' + dbo.fn_e3_montant(@ancienne) + N' devient ' + dbo.fn_e3_montant(@valeur)
                                                  + N' (version ' + CAST(@version AS NVARCHAR (10)) + N').'
                            ELSE N' inchangée : même valeur et même rapport.' END
           + CASE WHEN @rattachee = 1 THEN N' Le rapport est rattaché à l''actif.' ELSE N'' END AS message;
END;

GO

