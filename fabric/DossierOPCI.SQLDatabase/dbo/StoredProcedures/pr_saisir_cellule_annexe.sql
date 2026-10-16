
-- pr_saisir_cellule_annexe : 8 refus
-- La saisie d'une cellule (contrat, 3.1, point 1, et 3.3) : verrou au debut, avant toutes les gardes ; lignes variables
-- et lignes creees admises quand la ligne est dans la derniere version ; refus 50643 a 50647 pour l'ecriture d'une
-- valeur ; calcul SAISIE dans la transaction ; la peremption de la saisie n'est gardee que pour une ligne d'etat.
CREATE   PROCEDURE dbo.pr_saisir_cellule_annexe
    @entite  VARCHAR (20),
    @arrete  VARCHAR (20),
    @article VARCHAR (10),
    @ligne   NVARCHAR (300),
    @colonne NVARCHAR (120),
    @valeur  NVARCHAR (2000)  = NULL,
    @montant DECIMAL (19, 6)  = NULL,
    @motif   NVARCHAR (800)   = NULL,
    @par     NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @m NVARCHAR (2000), @etat VARCHAR (14), @premier BIT, @type VARCHAR (14),
            @maintenant DATETIME2 = SYSUTCDATETIME(), @existe INT, @action NVARCHAR (20), @perimes INT = 0, @perimes_calc INT = 0,
            @tc INT = @@TRANCOUNT, @ecrit BIT, @aucune BIT = 0,
            @c_trouvee BIT = 0, @c_nature VARCHAR (8), @c_etat VARCHAR (12), @c_format VARCHAR (10), @c_formule NVARCHAR (MAX),
            @c_vb NVARCHAR (2000), @c_texte NVARCHAR (2000), @c_source NVARCHAR (MAX), @ligne_version BIT = 0, @ref_ligne BIT = 0;
    SET @valeur = NULLIF(LTRIM(RTRIM(@valeur)), N'');
    SET @motif = NULLIF(LTRIM(RTRIM(@motif)), N'');
    SET @colonne = LTRIM(RTRIM(@colonne));
    SET @ecrit = CASE WHEN @valeur IS NOT NULL OR @montant IS NOT NULL THEN 1 ELSE 0 END;
    BEGIN TRY
    BEGIN TRANSACTION;
    EXEC dbo.pr_ann_verrou @entite = @entite;

    IF @colonne IS NULL OR @colonne NOT IN (N'1', N'2', N'3', N'4', N'5', N'6', N'7')
        THROW 50603, N'Saisie refusée : la colonne est numérotée de 1 à 7.', 1;
    IF @valeur IS NOT NULL AND @montant IS NOT NULL
        THROW 50604, N'Saisie refusée : une cellule porte une valeur ou un montant, pas les 2.', 1;
    SELECT @premier = premier_exercice FROM dbo.v_arrete_etat WHERE entite = @entite AND arrete = @arrete;
    IF @premier IS NULL
    BEGIN
        SET @m = N'Saisie refusée : l''arrêté ' + ISNULL(@arrete, N'vide') + N' de l''entité ' + ISNULL(@entite, N'vide')
               + N' n''est pas un arrêté de mission d''un véhicule ; il n''a pas d''annexe.';
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50633, @m, 1; END
    END;

    SET @etat = CASE @article WHEN '321-2' THEN 'BILAN_ACTIF' WHEN '321-6' THEN 'BILAN_PASSIF' WHEN '322-2' THEN 'RESULTAT' END;
    IF @etat IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM dbo.ref_ligne_etat WHERE etat = @etat AND code = @ligne AND type_ligne = 'DETAIL')
        BEGIN
            SET @m = N'Saisie refusée : la ligne ' + ISNULL(@ligne, N'vide') + N' n''existe pas à l''article ' + @article
                   + N', ou elle se calcule sur les autres lignes.';
            BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50602, @m, 1; END
        END;
        IF @colonne <> N'2' OR @premier = 0
            THROW 50608, N'Saisie refusée : la colonne N-1 d''un état ne se saisit qu''au 1er exercice suivi.', 1;
    END
    ELSE
    BEGIN
        -- la ligne : une ligne de ref_ligne_annexe, ou une ligne variable ou creee que porte la derniere version
        SELECT @type = type_ligne, @ref_ligne = 1 FROM dbo.ref_ligne_annexe WHERE article = @article AND code = @ligne;
        IF EXISTS (SELECT 1 FROM dbo.v_annexe_version v
                   JOIN dbo.cellule_annexe c ON c.entite = v.entite AND c.arrete = v.arrete AND c.version = v.derniere_version
                   WHERE v.entite = @entite AND v.arrete = @arrete AND c.article = @article AND c.ligne = @ligne)
            SET @ligne_version = 1;
        IF @ref_ligne = 0 AND @ligne_version = 0
        BEGIN
            SET @m = N'Saisie refusée : la ligne ' + ISNULL(@ligne, N'vide') + N' n''existe pas à l''article ' + ISNULL(@article, N'vide') + N'.';
            BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50602, @m, 1; END
        END;
        IF @type = 'RUBRIQUE' AND @ligne_version = 0
        BEGIN
            SET @m = N'Saisie refusée : la ligne ' + @ligne + N' de l''article ' + @article + N' est un intitulé, sans cellule.';
            BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50602, @m, 1; END
        END;
        SELECT @c_trouvee = 1, @c_nature = c.nature, @c_etat = c.etat, @c_format = c.format, @c_formule = c.formule, @c_vb = c.valeur_base,
               @c_texte = c.texte_affiche, @c_source = c.source
        FROM dbo.v_annexe_version v
        JOIN dbo.cellule_annexe c ON c.entite = v.entite AND c.arrete = v.arrete AND c.version = v.derniere_version
        WHERE v.entite = @entite AND v.arrete = @arrete AND c.article = @article AND c.ligne = @ligne AND CAST(c.colonne AS NVARCHAR (4)) = @colonne;
    END;

    IF dbo.fn_peut_saisir_annexe(@entite, @par, CAST(@maintenant AS DATE)) = 0
    BEGIN
        SET @m = N'Saisie refusée : cette personne ne peut pas saisir l''annexe de l''entité ' + @entite + N' : elle n''y tient aucun rôle de mission.';
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50606, @m, 1; END
    END;
    IF dbo.fn_valide_pour_client(@entite, @arrete) = 1
        THROW 50607, N'Saisie refusée : l''arrêté est validé pour le client ; la saisie suppose sa réouverture.', 1;

    SELECT @existe = id FROM dbo.saisie_annexe
    WHERE entite = @entite AND arrete = @arrete AND article = @article AND ligne = @ligne AND colonne = @colonne;
    IF @ecrit = 0 AND @existe IS NULL
        SET @aucune = 1;
    ELSE
    BEGIN
        -- l'ecriture d'une valeur sur une cellule de l'annexe (le retrait est toujours admis, 3.3, point 7)
        IF @ecrit = 1 AND @etat IS NULL
        BEGIN
            IF @c_trouvee = 0 AND @ligne_version = 1
            BEGIN
                SET @m = N'Saisie refusée : la ligne ' + @ligne + N' de l''article ' + @article + N' ne porte pas de colonne ' + @colonne + N'.';
                BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50603, @m, 1; END
            END;
            IF @c_nature = 'modele'
            BEGIN
                SET @m = N'Saisie refusée : la cellule ' + @article + N', ligne ' + @ligne + N', colonne ' + @colonne
                       + N' est sans objet au modèle du recueil ; elle ne porte aucune valeur.';
                BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50643, @m, 1; END
            END;
            IF @c_nature = 'calcul' OR @c_etat = 'EN_ATTENTE'
            BEGIN
                SET @m = N'Saisie refusée : la cellule ' + @article + N', ligne ' + @ligne + N', colonne ' + @colonne
                       + N' se calcule sur d''autres cellules de l''annexe (' + ISNULL(@c_formule, N'formule de la cellule') + N') ; saisissez ses opérandes.';
                SET @m = REPLACE(@m, N'%', N'%%');
                THROW 50644, @m, 1;
            END;
            IF @c_format IS NOT NULL AND ((@c_format = 'texte' AND @montant IS NOT NULL) OR (@c_format <> 'texte' AND @valeur IS NOT NULL))
            BEGIN
                SET @m = N'Saisie refusée : la colonne ' + @colonne + N' de l''article ' + @article + N' attend '
                       + CASE WHEN @c_format = 'texte' THEN N'un texte.' ELSE N'un montant.' END;
                BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50645, @m, 1; END
            END;
            IF @c_nature = 'etat' AND (@c_etat IN ('LU', 'CALCULE') OR (@c_etat = 'SAISI' AND @c_vb IS NOT NULL))
            BEGIN
                SET @m = N'Saisie refusée : la cellule reproduit une ligne de l''état (' + ISNULL(@c_source, N'') + N'), qui vaut '
                       + ISNULL(CASE WHEN @c_etat = 'SAISI' THEN @c_vb ELSE @c_texte END, N'') + N' ; une inscription dans l''annexe ne peut se substituer à une inscription au bilan ou au compte de résultat (article 331-1).';
                SET @m = REPLACE(@m, N'%', N'%%');
                THROW 50646, @m, 1;
            END;
            IF @article = '336-2' AND @colonne = N'7' AND @ligne LIKE N'FIL:%'
               AND (@valeur IS NULL OR LOWER(@valeur) NOT IN (N'contrôlée', N'non contrôlée'))
                THROW 50647, N'Saisie refusée : le classement d''une filiale au sens de l''article R. 214-83 du code monétaire et financier s''écrit « contrôlée » ou « non contrôlée ».', 1;
        END;
        IF @ecrit = 1 AND @motif IS NULL AND dbo.fn_cellule_exige_motif(@entite, @arrete, @article, @ligne, @colonne) = 1
            THROW 50605, N'Saisie refusée : cette cellule recouvre une valeur calculée, ou un exercice antérieur à la reprise ; elle exige un motif.', 1;

        EXEC sp_set_session_context N'saisie_annexe_par', @par;
        IF @ecrit = 0
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
        EXEC sp_set_session_context N'saisie_annexe_par', NULL;

        -- le calcul de la saisie, dans sa transaction : il perime les documents dont une cellule imprimee change
        EXEC dbo.pr_calculer_annexe @entite = @entite, @arrete = @arrete, @declencheur = 'SAISIE', @par = @par, @rendre = 0,
             @documents_perimes = @perimes_calc OUTPUT;
        -- une saisie d'une ligne d'etat change une ligne que les versions ne portent pas : peremption gardee (2.3, point 4)
        IF @etat IS NOT NULL
        BEGIN
            UPDATE dbo.document_produit
            SET perime_le = @maintenant,
                perime_motif = N'Périmé par la saisie de la cellule ' + @article + N', ligne ' + @ligne + N', colonne ' + @colonne
                             + N' (' + @action + N'), par ' + @par + N', le ' + CONVERT(NVARCHAR (19), @maintenant, 120) + N' UTC.'
            WHERE entite = @entite AND arrete = @arrete AND livrable IN ('COMPTES_ANNUELS', 'ATTESTATION') AND perime_le IS NULL;
            SET @perimes = @@ROWCOUNT;
        END;
        SET @perimes += ISNULL(@perimes_calc, 0);
    END;
    COMMIT;
    END TRY
    BEGIN CATCH
        IF @tc = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        EXEC sp_set_session_context N'saisie_annexe_par', NULL;
        THROW;
    END CATCH;

    IF @aucune = 1
        SELECT CAST(NULL AS INT) AS saisie_id, N'aucune' AS action, 0 AS documents_perimes,
               N'Aucune cellule saisie à retirer : la cellule rend déjà la valeur que la base calcule, ou « à remplir ».' AS message;
    ELSE
        SELECT CASE WHEN @action = N'retrait' THEN NULL ELSE @existe END AS saisie_id, @action AS action, @perimes AS documents_perimes,
               N'Cellule ' + @article + N', ligne ' + @ligne + N', colonne ' + @colonne + N' : ' + @action + CASE WHEN @action = N'modification' THEN N' enregistrée' ELSE N' enregistré' END
             + CASE WHEN @perimes > 0 THEN N' ; ' + CAST(@perimes AS NVARCHAR (12)) + N' document(s) produit(s) passent périmés.' ELSE N'.' END AS message;
END;

GO

