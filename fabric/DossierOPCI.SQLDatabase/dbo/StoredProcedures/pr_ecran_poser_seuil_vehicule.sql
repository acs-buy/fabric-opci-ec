-- ------------------------------------------------------------------ n° 24 : le seuil propre d'un vehicule, seule voie d'ecriture de ref_ratio_vehicule
-- ecran 5, lot 1, script 323 (61_DEPLOIEMENT/generer_e5_323_procedures_de_tenue.py)
-- Contrat de la maquette (objet n° 24), B5, B16, B19, B20, decision D9 ; raisons de [Etat du seuil du vehicule], dans
-- son ordre : le referentiel choisi ne porte pas de seuil propre (le code n'est pas une limite), le texte fixe la valeur
-- (valeur_laissee vide, ou STATUTS pour un OPCI grand public), le droit (fn_peut_ecrire_referentiel sur
-- ref_ratio_vehicule, que la garde tr_ref_ratio_vehicule_garde rejoue en 50074). Les 7 refus que la garde rejoue
-- (script 318, 50890 a 50894) ont leur condition, leur numero et leur texte ecrits depuis REGLES_323 du generateur du
-- 318, source unique : vehicule nomme par son code, U+202F avant le « % » d'une limite du texte. Le seuil se lit a
-- l'unite de la limite (unite_seuil) : TAUX, un pourcentage enregistre en fraction de 1 ; NOMBRE, tel quel.
-- ENDETTEMENT_40 (RETENUE) est admis pour un OPCI professionnel. MERGE sur (entite, code) ; message sous le vehicule.
CREATE   PROCEDURE dbo.pr_ecran_poser_seuil_vehicule
    @entite NVARCHAR (40)  = NULL,
    @code   NVARCHAR (240) = NULL,
    @seuil  NVARCHAR (60)  = NULL,
    @depuis NVARCHAR (40)  = NULL,
    @motif  NVARCHAR (MAX) = NULL,
    @par    NVARCHAR (400) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    -- @@TRANCOUNT lu seul, avant toute lecture de table : sous IMPLICIT_TRANSACTIONS (connexion sans autocommit d'une
    -- Data function), la 1re lecture ouvrirait la transaction de l'appelant avant la mesure
    DECLARE @tc INT = @@TRANCOUNT;
    DECLARE @journal_avant INT = ISNULL((SELECT MAX(id) FROM dbo.journal_refus), 0),
            @proc VARCHAR (60) = 'pr_ecran_poser_seuil_vehicule', @e_num INT, @e_msg NVARCHAR (2048), @e_fr NVARCHAR (2000),
            @e_journal NVARCHAR (2000), @e_entite VARCHAR (20), @m NVARCHAR (2000), @message NVARCHAR (2000);
    DECLARE @e VARCHAR (20), @forme_e VARCHAR (10), @pro BIT, @c VARCHAR (30), @lib_lim NVARCHAR (120), @article NVARCHAR (120),
            @limite NVARCHAR (60), @forme_l VARCHAR (10), @laissee VARCHAR (12), @unite VARCHAR (6), @s NVARCHAR (60),
            @d DECIMAL (38, 10), @valeur DECIMAL (9, 6), @date DATE, @affiche NVARCHAR (60);
    SELECT @par = NULLIF(LTRIM(RTRIM(@par)), N''), @entite = NULLIF(LTRIM(RTRIM(@entite)), N''), @code = NULLIF(LTRIM(RTRIM(@code)), N''),
           @seuil = NULLIF(LTRIM(RTRIM(@seuil)), N''), @depuis = NULLIF(LTRIM(RTRIM(@depuis)), N''), @motif = NULLIF(LTRIM(RTRIM(@motif)), N'');
    BEGIN TRY
        IF @par IS NULL
            EXEC dbo.pr_e5_refuser 50830, N'Action refusée : l’auteur de l’action n’est pas transmis ; l’écran le transmet avec l’adresse de connexion de la personne qui clique.';
        EXEC sp_set_session_context N'par', @par;
        IF @entite IS NULL
            EXEC dbo.pr_e5_refuser 50860, N'Choisissez le véhicule dans le sélecteur « Véhicule ».';
        -- le vehicule recu par son code, ou par la valeur du selecteur (ref_entite.libelle_vehicule, « CODE · nom »)
        SELECT TOP (1) @e = x.code, @forme_e = x.forme_vehicule, @pro = ISNULL(x.est_professionnel, 0) FROM dbo.ref_entite x
        WHERE x.code = @entite OR x.libelle_vehicule = @entite
           OR (CHARINDEX(NCHAR (183), @entite) > 1 AND x.code = LTRIM(RTRIM(LEFT(@entite, NULLIF(CHARINDEX(NCHAR (183), @entite), 0) - 1))))
        ORDER BY CASE WHEN x.code = @entite THEN 0 WHEN x.libelle_vehicule = @entite THEN 1 ELSE 2 END;
        IF @e IS NULL OR @forme_e IS NULL
        BEGIN
            SET @m = N'Seuil refusé : l’entité « ' + ISNULL(@e, @entite) + N' » n’est pas un OPCI ; un seuil propre ne se pose que sur un véhicule.';
            EXEC dbo.pr_e5_refuser 50860, @m;
        END;
        IF @code IS NULL
            EXEC dbo.pr_e5_refuser 50861, N'Choisissez la limite dans la liste « Ligne ».';
        SELECT TOP (1) @c = r.code, @lib_lim = r.libelle, @article = r.article, @limite = r.limite_texte, @forme_l = r.forme_vehicule,
                       @laissee = r.valeur_laissee, @unite = r.unite_seuil
        FROM dbo.ref_ratio_memoire r WHERE r.code = @code OR r.libelle = @code
        ORDER BY CASE WHEN r.code = @code THEN 0 ELSE 1 END;
        IF @c IS NULL
        BEGIN
            SET @m = N'Seuil refusé : le référentiel choisi ne porte pas de seuil propre ; le seuil d’un véhicule se pose sur une limite du référentiel « '
                   + dbo.fn_e5_libelle_referentiel('ref_ratio_memoire') + N' ».';
            EXEC dbo.pr_e5_refuser 50861, @m;
        END;
        -- la limite du texte telle que la base la porte, U+202F avant « % » (convention des refus, garde du script 318)
        SET @limite = REPLACE(@limite COLLATE Latin1_General_BIN2, N' %', NCHAR (8239) + N'%');
        IF @laissee IS NULL
        BEGIN
            SET @m = N'Seuil refusé : le texte fixe cette limite (' + @article + N', ' + @limite + N'). Seules les valeurs que le texte laisse au gestionnaire ou aux statuts se tiennent ici.';
            EXEC dbo.pr_e5_refuser 50862, @m;
        END;
        IF @laissee = 'STATUTS' AND @pro = 0
        BEGIN
            SET @m = N'Seuil refusé : le texte fixe cette limite pour un OPCI grand public (' + @article + N', ' + @limite + N') ; il ne la laisse aux statuts que pour un OPCI professionnel. Seules les valeurs que le texte laisse au gestionnaire ou aux statuts se tiennent ici.';
            EXEC dbo.pr_e5_refuser 50862, @m;
        END;
        IF dbo.fn_peut_ecrire_referentiel('ref_ratio_vehicule', @par) = 0
        BEGIN
            SET @m = N'Seuil refusé sur « ' + dbo.fn_e5_libelle_referentiel('ref_ratio_vehicule') + N' » : aucun droit de modification.';
            EXEC dbo.pr_e5_refuser 50859, @m;
        END;
        -- la forme : « une SPPICAV », « un FPI » (ck_entite_forme_vehicule : SPPICAV ou FPI)
        IF @forme_l IS NOT NULL AND @forme_l <> @forme_e
        BEGIN
            SET @m = N'Seuil refusé : la limite « ' + @lib_lim + N' » vaut pour ' + CASE @forme_l WHEN 'FPI' THEN N'un ' ELSE N'une ' END + @forme_l + N', et ' + @e + N' est ' + CASE @forme_e WHEN 'FPI' THEN N'un ' ELSE N'une ' END + @forme_e + N'.';
            EXEC dbo.pr_e5_refuser 50863, @m;
        END;
        IF @unite IS NULL OR @unite NOT IN ('TAUX', 'NOMBRE')
        BEGIN
            SET @m = N'Seuil refusé : l’unité du seuil propre de la limite « ' + @lib_lim + N' » n’est pas posée au référentiel des limites.';
            EXEC dbo.pr_e5_refuser 50864, @m;
        END;
        IF @seuil IS NULL
        BEGIN
            SET @m = N'Le champ « Seuil du véhicule » est obligatoire : '
                   + CASE WHEN @unite = 'TAUX' THEN N'un pourcentage, comme « 35 » ou « 35' + NCHAR (8239) + N'% ».'
                          ELSE N'un nombre de fois la valeur nette d’inventaire, comme « 2 ».' END;
            EXEC dbo.pr_e5_refuser 50864, @m;
        END;
        SET @s = REPLACE(REPLACE(REPLACE(@seuil COLLATE Latin1_General_BIN2, N' ', N''), NCHAR (160), N''), NCHAR (8239), N'');
        IF RIGHT(@s, 1) = N'%'
        BEGIN
            IF @unite <> 'TAUX'
            BEGIN
                SET @m = N'« Seuil du véhicule » : la limite « ' + @lib_lim + N' » s’exprime en nombre de fois la valeur nette d’inventaire, sans « % ».';
                EXEC dbo.pr_e5_refuser 50864, @m;
            END;
            SET @s = LEFT(@s, LEN(@s) - 1);
        END;
        SET @d = dbo.fn_e5_nombre(@s);
        IF @d IS NULL
        BEGIN
            SET @m = N'« Seuil du véhicule » : « ' + @seuil + N' » n’est pas un nombre.';
            EXEC dbo.pr_e5_refuser 50864, @m;
        END;
        IF @d < 0
            EXEC dbo.pr_e5_refuser 50865, N'« Seuil du véhicule » : un seuil n’est pas négatif.';
        IF @unite = 'TAUX' AND @d > 100
        BEGIN
            SET @m = N'« Seuil du véhicule » : un taux ne dépasse pas 100' + NCHAR (8239) + N'%.';
            EXEC dbo.pr_e5_refuser 50865, @m;
        END;
        IF @unite = 'TAUX' SET @d = @d / 100;
        IF @d <> ROUND(@d, 6) OR @d >= 1000
        BEGIN
            SET @m = CASE WHEN @unite = 'TAUX' THEN N'« Seuil du véhicule » : un taux porte au plus 4 décimales.'
                          ELSE N'« Seuil du véhicule » : un nombre de fois la valeur nette d’inventaire porte au plus 6 décimales et reste sous 1 000.' END;
            EXEC dbo.pr_e5_refuser 50865, @m;
        END;
        SET @valeur = CAST(@d AS DECIMAL (9, 6));
        IF @depuis IS NULL
            EXEC dbo.pr_e5_refuser 50866, N'Le champ « En vigueur depuis » est obligatoire : la date à partir de laquelle le seuil s’applique, en jj/mm/aaaa.';
        SET @date = dbo.fn_e5_date(@depuis);
        IF @date IS NULL
        BEGIN
            SET @m = N'« En vigueur depuis » : « ' + @depuis + N' » n’est pas une date jj/mm/aaaa.';
            EXEC dbo.pr_e5_refuser 50866, @m;
        END;
        IF LEN(@motif) > 600
        BEGIN
            SET @m = N'« Motif » : ' + CAST(LEN(@motif) AS NVARCHAR (12)) + N' caractères, pour 600 au plus.';
            EXEC dbo.pr_e5_refuser 50867, @m;
        END;
        BEGIN TRANSACTION;
        MERGE dbo.ref_ratio_vehicule AS v
        USING (SELECT @e AS entite, @c AS code) AS s ON v.entite = s.entite AND v.code = s.code
        WHEN MATCHED THEN
            UPDATE SET v.seuil = @valeur, v.source = @laissee, v.en_vigueur_depuis = @date, v.motif = @motif,
                       v.lu_le = CAST(SYSUTCDATETIME() AS DATE), v.piece_id = NULL
        WHEN NOT MATCHED THEN
            INSERT (entite, code, seuil, source, piece_id, lu_le, en_vigueur_depuis, motif, modifie_par, modifie_le)
            VALUES (@e, @c, @valeur, @laissee, NULL, CAST(SYSUTCDATETIME() AS DATE), @date, @motif, @par, SYSUTCDATETIME());
        SET @affiche = CASE WHEN @unite = 'TAUX' THEN FORMAT(@valeur * 100, N'0.####', 'fr-FR') + NCHAR (8239) + N'%'
                            ELSE FORMAT(@valeur, N'0.######', 'fr-FR') END;
        SET @message = N'Seuil du véhicule enregistré : ' + @e + N', « ' + @lib_lim + N' », ' + @affiche
                     + CASE @laissee WHEN 'STATUTS' THEN N', fixé par les statuts' ELSE N', fixé par le gestionnaire' END
                     + N', en vigueur depuis le ' + CONVERT(NVARCHAR (10), @date, 103) + N'.';
        EXEC dbo.pr_poser_message_ecran @pour = @par, @message = @message, @genre = 'SUCCES', @entite = @e, @procedure_nom = @proc;
        COMMIT TRANSACTION;
        EXEC sp_set_session_context N'par', NULL;
        SELECT @e AS vehicule, @message AS message;
    END TRY
    BEGIN CATCH
        SELECT @e_num = ERROR_NUMBER(), @e_msg = ERROR_MESSAGE();
        IF @tc = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        BEGIN TRY EXEC sp_set_session_context N'par', NULL; END TRY BEGIN CATCH END CATCH;
        SET @e_fr = dbo.fn_e5_traduire_erreur(@e_num, @e_msg);
        -- un refus de garde (ROLLBACK, inscription, THROW, objet n° 17) recu sous 266 ou 3609 : son texte francais est
        -- la ligne qu'un declencheur a inscrite pour @par depuis l'entree
        IF @e_fr IS NULL AND @e_num IN (266, 3609) AND @par IS NOT NULL
            SELECT TOP (1) @e_fr = j.message FROM dbo.journal_refus j
            WHERE j.id > @journal_avant AND j.procedure_nom LIKE 'tr[_]%' AND j.refuse_pour = LEFT(@par, 200)
            ORDER BY j.id DESC;
        SET @e_journal = ISNULL(@e_fr, @e_msg);
        SET @e_entite = ISNULL(@e, '-');
        EXEC dbo.pr_e5_conclure_refus @tc, @journal_avant, @proc, @par, @e_entite, @e_journal;
        IF @e_fr IS NOT NULL EXEC dbo.pr_e5_refuser 50868, @e_fr;
        THROW;
    END CATCH;
END;

GO

