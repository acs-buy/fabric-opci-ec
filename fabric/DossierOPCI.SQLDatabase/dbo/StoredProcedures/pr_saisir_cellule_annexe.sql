


-- 8. « arrete sans annexe » en 50633.
CREATE   PROCEDURE dbo.pr_saisir_cellule_annexe
    @entite  VARCHAR (20),
    @arrete  VARCHAR (20),
    @article VARCHAR (10),
    @ligne   NVARCHAR (300),
    @colonne NVARCHAR (120),
    @valeur  NVARCHAR (2000)  = NULL,
    @montant DECIMAL (19, 2)  = NULL,
    @motif   NVARCHAR (800)   = NULL,
    @par     NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @m NVARCHAR (800), @etat VARCHAR (14), @premier BIT, @type VARCHAR (14),
            @maintenant DATETIME2 = SYSUTCDATETIME(), @existe INT, @action NVARCHAR (20), @perimes INT = 0;
    SET @valeur = NULLIF(LTRIM(RTRIM(@valeur)), N'');
    SET @motif = NULLIF(LTRIM(RTRIM(@motif)), N'');
    SET @colonne = LTRIM(RTRIM(@colonne));

    IF @colonne IS NULL OR @colonne NOT IN (N'1', N'2', N'3', N'4', N'5', N'6', N'7')
        THROW 50603, N'Saisie refusée : la colonne est numérotée de 1 à 7.', 1;
    IF @valeur IS NOT NULL AND @montant IS NOT NULL
        THROW 50604, N'Saisie refusée : une cellule porte une valeur ou un montant, pas les 2.', 1;
    SELECT @premier = premier_exercice FROM dbo.v_arrete_etat WHERE entite = @entite AND arrete = @arrete;
    IF @premier IS NULL
    BEGIN
        SET @m = N'Saisie refusée : l''arrêté ' + ISNULL(@arrete, N'vide') + N' de l''entité ' + ISNULL(@entite, N'vide')
               + N' n''est pas un arrêté de mission d''un véhicule ; il n''a pas d''annexe.';
        THROW 50633, @m, 1;
    END;

    SET @etat = CASE @article WHEN '321-2' THEN 'BILAN_ACTIF' WHEN '321-6' THEN 'BILAN_PASSIF' WHEN '322-2' THEN 'RESULTAT' END;
    IF @etat IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM dbo.ref_ligne_etat WHERE etat = @etat AND code = @ligne AND type_ligne = 'DETAIL')
        BEGIN
            SET @m = N'Saisie refusée : la ligne ' + ISNULL(@ligne, N'vide') + N' n''existe pas à l''article ' + @article
                   + N', ou elle se calcule sur les autres lignes.';
            THROW 50602, @m, 1;
        END;
        IF @colonne <> N'2' OR @premier = 0
            THROW 50608, N'Saisie refusée : la colonne N-1 d''un état ne se saisit qu''au 1er exercice suivi.', 1;
    END
    ELSE
    BEGIN
        SELECT @type = type_ligne FROM dbo.ref_ligne_annexe WHERE article = @article AND code = @ligne;
        IF @type IS NULL
        BEGIN
            SET @m = N'Saisie refusée : la ligne ' + ISNULL(@ligne, N'vide') + N' n''existe pas à l''article ' + ISNULL(@article, N'vide') + N'.';
            THROW 50602, @m, 1;
        END;
        IF @type = 'RUBRIQUE'
        BEGIN
            SET @m = N'Saisie refusée : la ligne ' + @ligne + N' de l''article ' + @article + N' est un intitulé, sans cellule.';
            THROW 50602, @m, 1;
        END;
        IF @colonne <> N'1' AND EXISTS (SELECT 1 FROM dbo.ref_ligne_annexe WHERE article = @article AND code = @ligne AND formule_calcul LIKE N'%; colonne 1 seule%')
        BEGIN
            SET @m = N'Saisie refusée : la ligne ' + @ligne + N' de l''article ' + @article + N' ne porte que la colonne 1, comme au recueil.';
            THROW 50603, @m, 1;
        END;
    END;

    IF dbo.fn_peut_saisir_annexe(@entite, @par, CAST(@maintenant AS DATE)) = 0
    BEGIN
        SET @m = N'Saisie refusée : cette personne ne peut pas saisir l''annexe de l''entité ' + @entite + N' : elle n''y tient aucun rôle de mission.';
        THROW 50606, @m, 1;
    END;
    IF dbo.fn_valide_pour_client(@entite, @arrete) = 1
        THROW 50607, N'Saisie refusée : l''arrêté est validé pour le client ; la saisie suppose sa réouverture.', 1;

    SELECT @existe = id FROM dbo.saisie_annexe
    WHERE entite = @entite AND arrete = @arrete AND article = @article AND ligne = @ligne AND colonne = @colonne;
    IF @valeur IS NULL AND @montant IS NULL AND @existe IS NULL
    BEGIN
        SELECT CAST(NULL AS INT) AS saisie_id, N'aucune' AS action, 0 AS documents_perimes,
               N'Aucune cellule saisie à retirer : la cellule rend déjà la valeur que la base calcule, ou « à remplir ».' AS message;
        RETURN;
    END;
    IF (@valeur IS NOT NULL OR @montant IS NOT NULL) AND @motif IS NULL
       AND dbo.fn_cellule_exige_motif(@entite, @arrete, @article, @ligne, @colonne) = 1
        THROW 50605, N'Saisie refusée : cette cellule recouvre une valeur calculée, ou un exercice antérieur à la reprise ; elle exige un motif.', 1;

    BEGIN TRY
        EXEC sp_set_session_context N'saisie_annexe_par', @par;
        BEGIN TRANSACTION;
        IF @valeur IS NULL AND @montant IS NULL
        BEGIN
            DELETE dbo.saisie_annexe WHERE id = @existe;
            SET @action = N'retrait';
        END
        ELSE IF @existe IS NOT NULL
        BEGIN
            UPDATE dbo.saisie_annexe
            SET valeur = @valeur, montant = @montant, saisi_par = @par, saisi_le = @maintenant,
                motif = @motif, motif_par = CASE WHEN @motif IS NOT NULL THEN @par END,
                motif_le = CASE WHEN @motif IS NOT NULL THEN @maintenant END
            WHERE id = @existe;
            SET @action = N'modification';
        END
        ELSE
        BEGIN
            INSERT INTO dbo.saisie_annexe (entite, arrete, article, ligne, colonne, valeur, montant, saisi_par, saisi_le, motif, motif_par, motif_le)
            VALUES (@entite, @arrete, @article, @ligne, @colonne, @valeur, @montant, @par, @maintenant,
                    @motif, CASE WHEN @motif IS NOT NULL THEN @par END, CASE WHEN @motif IS NOT NULL THEN @maintenant END);
            SET @existe = SCOPE_IDENTITY();
            SET @action = N'ajout';
        END;

        -- les comptes annuels et le rapport de l'expert-comptable produits avant la saisie ne refletent plus la base
        UPDATE dbo.document_produit
        SET perime_le = @maintenant,
            perime_motif = N'Périmé par la saisie de la cellule ' + @article + N', ligne ' + @ligne + N', colonne ' + @colonne
                         + N' (' + @action + N'), par ' + @par + N', le ' + CONVERT(NVARCHAR (19), @maintenant, 120) + N' UTC.'
        WHERE entite = @entite AND arrete = @arrete AND livrable IN ('COMPTES_ANNUELS', 'ATTESTATION') AND perime_le IS NULL;
        SET @perimes = @@ROWCOUNT;
        COMMIT;
        EXEC sp_set_session_context N'saisie_annexe_par', NULL;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        EXEC sp_set_session_context N'saisie_annexe_par', NULL;
        THROW;
    END CATCH;

    SELECT CASE WHEN @action = N'retrait' THEN NULL ELSE @existe END AS saisie_id, @action AS action, @perimes AS documents_perimes,
           N'Cellule ' + @article + N', ligne ' + @ligne + N', colonne ' + @colonne + N' : ' + @action + CASE WHEN @action = N'modification' THEN N' enregistrée' ELSE N' enregistré' END
         + CASE WHEN @perimes > 0 THEN N' ; ' + CAST(@perimes AS NVARCHAR (12)) + N' document(s) produit(s) avant la saisie passent périmés.' ELSE N'.' END AS message;
END;

GO

