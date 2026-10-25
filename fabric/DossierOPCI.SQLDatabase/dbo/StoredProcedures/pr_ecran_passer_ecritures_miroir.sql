
CREATE   PROCEDURE dbo.pr_ecran_passer_ecritures_miroir
    @entite VARCHAR (20),
    @arrete VARCHAR (20),
    @par    NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    -- 327 debut (24/10/2026) : un champ vide se refuse en francais avant toute ecriture, au texte du champ dans le
    -- plan de l'etude des fonctions (decision A du candidat). Genere par 61_DEPLOIEMENT/generer_327_refus_champs_vides.py.
    -- Place : avant fn_e3_refus_commun, dans l'ordre du plan : arrete, puis entite avant 50701.
    -- le vide : les 29 caracteres de str.isspace(), compares au point de code
    DECLARE @r327_blancs NVARCHAR (29) = NCHAR(9) + NCHAR(10) + NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(28) + NCHAR(29) + NCHAR(30) + NCHAR(31) + NCHAR(32)
        + NCHAR(133) + NCHAR(160) + NCHAR(5760) + NCHAR(8192) + NCHAR(8193) + NCHAR(8194) + NCHAR(8195) + NCHAR(8196) + NCHAR(8197) + NCHAR(8198)
        + NCHAR(8199) + NCHAR(8200) + NCHAR(8201) + NCHAR(8202) + NCHAR(8232) + NCHAR(8233) + NCHAR(8239) + NCHAR(8287) + NCHAR(12288);
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @arrete COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51202, N'Choisissez l''arrêté dans le sélecteur Arrêté.', 1;
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @entite COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51238, N'Passage refusé : aucune écriture miroir à passer pour le véhicule du sélecteur Véhicule à cet arrêté.', 1;
    -- 327 fin
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

