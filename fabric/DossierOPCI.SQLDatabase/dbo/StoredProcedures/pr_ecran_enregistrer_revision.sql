
-- pr_ecran_enregistrer_revision : 1 refus
-- ------------------------------------------------------------------ n° 4 : la revision d'une avance (213-4)
CREATE   PROCEDURE dbo.pr_ecran_enregistrer_revision
    @vehicule       VARCHAR (20),
    @arrete         VARCHAR (20),
    @code_actif     VARCHAR (20),
    @montant_revise DECIMAL (19,2),
    @motif          NVARCHAR (600),
    @par            NVARCHAR (400)
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
    DECLARE @detentrice VARCHAR (20), @fille VARCHAR (20), @nominal DECIMAL (19,2), @compte VARCHAR (20), @m NVARCHAR (1000);
    SELECT @detentrice = entite_detentrice, @fille = entite_liee, @nominal = prix_de_revient, @compte = poste_bilan
    FROM dbo.actif WHERE code = @code_actif AND nature = 'AVANCE_COMPTE_COURANT';
    IF @detentrice IS NULL OR @fille IS NULL
        THROW 50740, N'Choisissez une avance en compte courant à une filiale dans la grille des avances.', 1;
    IF @montant_revise IS NULL
        THROW 50741, N'Le montant révisé est obligatoire.', 1;
    SET @motif = NULLIF(LTRIM(RTRIM(@motif)), N'');
    IF @motif IS NULL
        THROW 50742, N'Le motif de la révision est obligatoire.', 1;
    IF @montant_revise < 0 OR @montant_revise > @nominal
    BEGIN
        SET @m = N'Le montant révisé est compris entre 0 et le nominal de l''avance, ' + dbo.fn_e3_montant(@nominal) + N' : la révision se fait à la baisse.';
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50743, @m, 1; END
    END;
    DECLARE @tc INT = @@TRANCOUNT;
    BEGIN TRY
        BEGIN TRANSACTION;
        EXEC dbo.pr_e3_verrouiller @entite = @detentrice;
        UPDATE dbo.revision_compte_courant
           SET montant_nominal = @nominal, montant_revise = @montant_revise, motif = @motif, saisi_par = @par, saisi_le = SYSUTCDATETIME()
         WHERE entite = @detentrice AND arrete = @arrete AND entite_fille = @fille AND compte = @compte;
        IF @@ROWCOUNT = 0
            INSERT INTO dbo.revision_compte_courant (entite, arrete, entite_fille, compte, montant_nominal, montant_revise, motif, saisi_par, saisi_le)
            VALUES (@detentrice, @arrete, @fille, @compte, @nominal, @montant_revise, @motif, @par, SYSUTCDATETIME());
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @tc = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
    SELECT @vehicule AS vehicule,
           N'Révision de l''avance ' + @code_actif + N' à ' + @fille + N' enregistrée : nominal ' + dbo.fn_e3_montant(@nominal)
           + N', montant révisé ' + dbo.fn_e3_montant(@montant_revise) + N'.' AS message;
END;

GO

