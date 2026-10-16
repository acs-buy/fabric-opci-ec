
-- ------------------------------------------------------------------ n° 5 : le cours d'un titre 256 ou 258 du vehicule
CREATE   PROCEDURE dbo.pr_ecran_enregistrer_cours
    @vehicule   VARCHAR (20),
    @arrete     VARCHAR (20),
    @code_actif VARCHAR (20),
    @quantite   DECIMAL (19,4),
    @cours      DECIMAL (19,4),
    @source     NVARCHAR (200),
    @par        NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @r NVARCHAR (1000) = dbo.fn_e3_refus_commun(@vehicule, @arrete, @par);
    IF @r IS NOT NULL EXEC dbo.pr_e3_refuser @r;
    IF NULLIF(LTRIM(RTRIM(@code_actif)), '') IS NULL
        THROW 50703, N'Choisissez le titre dans la liste « Titre ».', 1;
    DECLARE @compte VARCHAR (20) = (SELECT LEFT(poste_bilan, 3) FROM dbo.actif
                                    WHERE code = @code_actif AND entite_detentrice = @vehicule AND LEFT(poste_bilan, 3) IN ('256', '258'));
    IF @compte IS NULL
        THROW 50750, N'Le cours se saisit pour un titre du véhicule inscrit au compte 256 ou 258.', 1;
    IF @quantite IS NULL OR @quantite <= 0
        THROW 50751, N'La quantité est obligatoire et supérieure à 0.', 1;
    IF @cours IS NULL OR @cours < 0
        THROW 50752, N'Le cours est obligatoire et ne peut pas être négatif.', 1;
    SET @source = NULLIF(LTRIM(RTRIM(@source)), N'');
    IF @source IS NULL
        THROW 50753, N'La source du cours est obligatoire.', 1;
    DECLARE @tc INT = @@TRANCOUNT;
    BEGIN TRY
        BEGIN TRANSACTION;
        EXEC dbo.pr_e3_verrouiller @entite = @vehicule;
        UPDATE dbo.cours_titre SET compte = @compte, quantite = @quantite, cours = @cours, source = @source, saisi_par = @par, saisi_le = SYSUTCDATETIME()
         WHERE entite = @vehicule AND arrete = @arrete AND code_actif = @code_actif;
        IF @@ROWCOUNT = 0
            INSERT INTO dbo.cours_titre (entite, arrete, code_actif, compte, quantite, cours, source, saisi_par, saisi_le)
            VALUES (@vehicule, @arrete, @code_actif, @compte, @quantite, @cours, @source, @par, SYSUTCDATETIME());
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @tc = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
    SELECT @vehicule AS vehicule,
           N'Cours de ' + @code_actif + N' au ' + dbo.fn_date_ecran(@arrete) + N' enregistré : ' + dbo.fn_e3_montant(@quantite)
           + N' titres à ' + dbo.fn_e3_montant(@cours) + N'.' AS message;
END;

GO

