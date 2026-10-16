
CREATE   PROCEDURE dbo.pr_ecran_passer_ecritures_miroir
    @entite VARCHAR (20),
    @arrete VARCHAR (20),
    @par    NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @r NVARCHAR (1000) = dbo.fn_e3_refus_commun(@entite, @arrete, @par);
    IF @r IS NOT NULL EXEC dbo.pr_e3_refuser @r;
    DECLARE @lots INT, @lignes INT;
    SELECT @lots = COUNT(DISTINCT m.entite), @lignes = COUNT(*)
    FROM dbo.v_ecriture_miroir_a_passer m
    WHERE m.arrete = @arrete AND m.montant_retenu > 0 AND NOT (m.nature = 'DIVIDENDE' AND m.compte_tresorerie IS NULL)
      AND m.entite IN (SELECT p.entite FROM dbo.v_perimetre_vehicule p WHERE p.vehicule = @entite AND p.arrete = @arrete);
    IF @lignes = 0
        THROW 50790, N'Aucune écriture miroir n''est à passer pour ce véhicule et ses filiales à cet arrêté.', 1;
    DECLARE @tc INT = @@TRANCOUNT;
    BEGIN TRY
        BEGIN TRANSACTION;
        -- le seul verrou de ce vehicule (pr_passer_ecritures_miroir verrouille tous les vehicules de l'arrete)
        EXEC dbo.pr_ann_verrou @entite = @entite;
        EXEC dbo.pr_passer_ecritures_miroir_corps @arrete = @arrete, @natures = NULL, @a_blanc = 0, @par = @par,
             @vehicule = @entite, @silencieux = 1;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @tc = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
    SELECT @entite AS vehicule,
           CAST(@lots AS NVARCHAR (10)) + N' lot(s) d''écritures miroir posé(s), ' + CAST(@lignes AS NVARCHAR (10))
           + N' flux : ils sont au statut proposé et attendent le visa du chef de mission.' AS message;
END;

GO

