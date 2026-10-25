
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

