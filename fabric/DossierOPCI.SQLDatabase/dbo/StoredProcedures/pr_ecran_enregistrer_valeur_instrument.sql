
-- ------------------------------------------------------------------ n° 6 : la valeur d'un instrument de classe 3 (113-2)
CREATE   PROCEDURE dbo.pr_ecran_enregistrer_valeur_instrument
    @vehicule        VARCHAR (20),
    @arrete          VARCHAR (20),
    @code_actif      VARCHAR (20),
    @valeur_actuelle DECIMAL (19,2),
    @source          NVARCHAR (200),
    @piece_id        INT = NULL,
    @par             NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    -- 327 debut (24/10/2026) : un champ vide se refuse en francais avant toute ecriture, au texte du champ dans le
    -- plan de l'etude des fonctions (decision A du candidat). Genere par 61_DEPLOIEMENT/generer_327_refus_champs_vides.py.
    -- Place : avant fn_e3_refus_commun : l'arrete vide d'un vehicule choisi passe avant 50702 ; le vehicule vide garde 50701.
    -- le vide : les 29 caracteres de str.isspace(), compares au point de code
    DECLARE @r327_blancs NVARCHAR (29) = NCHAR(9) + NCHAR(10) + NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(28) + NCHAR(29) + NCHAR(30) + NCHAR(31) + NCHAR(32)
        + NCHAR(133) + NCHAR(160) + NCHAR(5760) + NCHAR(8192) + NCHAR(8193) + NCHAR(8194) + NCHAR(8195) + NCHAR(8196) + NCHAR(8197) + NCHAR(8198)
        + NCHAR(8199) + NCHAR(8200) + NCHAR(8201) + NCHAR(8202) + NCHAR(8232) + NCHAR(8233) + NCHAR(8239) + NCHAR(8287) + NCHAR(12288);
    IF DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @vehicule COLLATE Latin1_General_100_BIN2)) > 0 AND ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @arrete COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51202, N'Choisissez l''arrêté dans le sélecteur Arrêté.', 1;
    -- 327 fin
    DECLARE @r NVARCHAR (1000) = COALESCE(dbo.fn_e3_refus_commun(@vehicule, @arrete, @par), dbo.fn_e3_refus_actif(@vehicule, @arrete, @code_actif));
    IF @r IS NOT NULL EXEC dbo.pr_e3_refuser @r;
    DECLARE @detentrice VARCHAR (20), @compte VARCHAR (20), @comptable DECIMAL (19,2);
    SELECT @detentrice = entite_detentrice, @compte = poste_bilan, @comptable = prix_de_revient
    FROM dbo.actif WHERE code = @code_actif AND LEFT(poste_bilan, 1) = '3';
    IF @detentrice IS NULL
        THROW 50755, N'La valeur se saisit pour un instrument financier inscrit en classe 3.', 1;
    IF @valeur_actuelle IS NULL
        THROW 50756, N'La valeur actuelle est obligatoire.', 1;
    SET @source = NULLIF(LTRIM(RTRIM(@source)), N'');
    IF @source IS NULL
        THROW 50757, N'La source de la valeur est obligatoire.', 1;
    IF @piece_id IS NOT NULL AND dbo.fn_e3_piece_du_perimetre(@vehicule, @arrete, @piece_id, NULL) = 0
        THROW 50758, N'La pièce choisie n''est pas déposée pour ce véhicule ou l''une de ses filiales.', 1;
    -- la valeur comptable : celle de la balance quand v_patrimoine_valorise la porte, le prix de revient sinon
    SET @comptable = ISNULL((SELECT TOP (1) valeur_comptable FROM dbo.v_patrimoine_valorise
                             WHERE entite = @detentrice AND arrete = @arrete AND code_actif = @code_actif), @comptable);
    DECLARE @tc INT = @@TRANCOUNT;
    BEGIN TRY
        BEGIN TRANSACTION;
        EXEC dbo.pr_e3_verrouiller @entite = @detentrice;
        UPDATE dbo.valeur_instrument
           SET compte = @compte, valeur_comptable = @comptable, valeur_actuelle = @valeur_actuelle, source = @source, piece_id = @piece_id,
               saisi_par = @par, saisi_le = SYSUTCDATETIME()
         WHERE entite = @detentrice AND arrete = @arrete AND code_actif = @code_actif;
        IF @@ROWCOUNT = 0
            INSERT INTO dbo.valeur_instrument (entite, arrete, code_actif, compte, valeur_comptable, valeur_actuelle, source, piece_id, saisi_par, saisi_le)
            VALUES (@detentrice, @arrete, @code_actif, @compte, @comptable, @valeur_actuelle, @source, @piece_id, @par, SYSUTCDATETIME());
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @tc = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
    SELECT @vehicule AS vehicule,
           N'Valeur de ' + @code_actif + N' au ' + dbo.fn_date_ecran(@arrete) + N' enregistrée : ' + dbo.fn_e3_montant(@valeur_actuelle)
           + N', valeur comptable ' + dbo.fn_e3_montant(@comptable) + N'.' AS message;
END;

GO

