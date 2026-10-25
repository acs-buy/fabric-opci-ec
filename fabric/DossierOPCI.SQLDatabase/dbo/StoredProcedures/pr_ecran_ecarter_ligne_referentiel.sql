-- ------------------------------------------------------------------ n° 14 : ecarter une ligne, colonnes d'ecart de l'objet n° 10
-- ecran 5, lot 1, script 323 (61_DEPLOIEMENT/generer_e5_323_procedures_de_tenue.py)
-- Raisons de [Blocage ecarter la ligne], dans l'ordre de blocages() de la maquette : mode TEXTE, action_propre, droit,
-- actions_de_ligne 0, puis referentiel sans colonnes d'ecart (decision D-c de la session base des 19 et 20/10/2026) :
-- ref_norme, ref_question, ref_reference et ref_sujet_tenue refusent en 50855, avant toute ecriture, avec la raison que
-- la mesure nomme (RAISONS_SANS_ECART), le bouton etant gris ; un autre referentiel sans colonnes d'ecart (COL_LENGTH
-- lu a l'execution ; aucun au 20/10/2026, controle C9) refuse en 50855 en nommant les 3 colonnes absentes. Une ligne
-- deja ecartee refuse en 50857 en nommant la ligne et la date de son ecart, la raison que [Blocage ecarter la ligne]
-- nomme (« ligne écartée depuis le jj/mm/aaaa », ecartee_le de v_ecran_referentiel_lignes, script 321), le bouton gris.
-- Motif facultatif, 600 caracteres au plus (contrat n° 14, B21).
CREATE   PROCEDURE dbo.pr_ecran_ecarter_ligne_referentiel
    @referentiel NVARCHAR (200) = NULL,
    @cle         NVARCHAR (400) = NULL,
    @motif       NVARCHAR (MAX) = NULL,
    @par         NVARCHAR (400) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    -- @@TRANCOUNT lu seul, avant toute lecture de table : sous IMPLICIT_TRANSACTIONS (connexion sans autocommit d'une
    -- Data function), la 1re lecture ouvrirait la transaction de l'appelant avant la mesure
    DECLARE @tc INT = @@TRANCOUNT;
    DECLARE @journal_avant INT = ISNULL((SELECT MAX(id) FROM dbo.journal_refus), 0),
            @proc VARCHAR (60) = 'pr_ecran_ecarter_ligne_referentiel', @e_num INT, @e_msg NVARCHAR (2048), @e_fr NVARCHAR (2000),
            @e_journal NVARCHAR (2000), @e_entite VARCHAR (20), @m NVARCHAR (2000), @message NVARCHAR (2000);
    DECLARE @t VARCHAR (120), @lib NVARCHAR (160), @mode VARCHAR (5), @actions TINYINT, @propre NVARCHAR (60), @designation VARCHAR (128),
            @clause NVARCHAR (MAX), @affectation NVARCHAR (MAX), @k1 NVARCHAR (400), @k2 NVARCHAR (400), @canon NVARCHAR (400), @ligne NVARCHAR (400),
            @existe BIT, @le DATE, @sql NVARCHAR (MAX), @nb INT;
    SELECT @par = NULLIF(LTRIM(RTRIM(@par)), N''), @cle = NULLIF(LTRIM(RTRIM(@cle)), N''), @motif = NULLIF(LTRIM(RTRIM(@motif)), N'');
    BEGIN TRY
        IF @par IS NULL
            EXEC dbo.pr_e5_refuser 50830, N'Action refusée : l’auteur de l’action n’est pas transmis ; l’écran le transmet avec l’adresse de connexion de la personne qui clique.';
        EXEC sp_set_session_context N'par', @par;
        EXEC dbo.pr_e5_lire_referentiel @referentiel, @t OUTPUT, @lib OUTPUT, @mode OUTPUT, @actions OUTPUT, @propre OUTPUT, @designation OUTPUT;
        IF @mode = 'TEXTE'
        BEGIN
            SET @m = N'Écart refusé sur « ' + @lib + N' » : fixé par un texte, non modifiable.';
            EXEC dbo.pr_e5_refuser 50832, @m;
        END;
        IF @propre IS NOT NULL
        BEGIN
            SET @m = N'Écart refusé sur « ' + @lib + N' » : seuil propre au véhicule, posé par « Enregistrer le seuil du véhicule ».';
            EXEC dbo.pr_e5_refuser 50833, @m;
        END;
        IF dbo.fn_peut_ecrire_referentiel(@t, @par) = 0
        BEGIN
            SET @m = N'Écart refusé sur « ' + @lib + N' » : aucun droit de modification.';
            EXEC dbo.pr_e5_refuser 50859, @m;
        END;
        IF @actions = 0
        BEGIN
            SET @m = N'Écart refusé sur « ' + @lib + N' » : seule la valeur se modifie : les codes des paramètres sont fixés par l’outil.';
            EXEC dbo.pr_e5_refuser 50834, @m;
        END;
        -- decision D-c : les 4 referentiels sans colonnes d'ecart, la raison de [Blocage ecarter la ligne] (SWITCH sur
        -- [Referentiel choisi]), qui ne depend pas de la ligne choisie
        IF @t IN ('ref_norme', 'ref_question', 'ref_reference', 'ref_sujet_tenue')
        BEGIN
            SET @m = N'Écart refusé sur « ' + @lib + N' » : ' + CASE @t
                WHEN 'ref_norme' THEN N'une norme hors d’usage se marque par « Modifier la valeur » : « Abrogée par » renseignée et « Applicable à la mission de présentation » à « non » avant « En vigueur » à « non »'
                WHEN 'ref_question' THEN N'une question de référence s’écarte par « Écarter la question », à l’étape 3'
                WHEN 'ref_reference' THEN N'une référence hors d’usage se marque par « Modifier la valeur » : « Abrogé par » renseigné avant « Abrogé le »'
                WHEN 'ref_sujet_tenue' THEN N'un sujet des questions sur la tenue ne garde ni date ni motif d’écart'
                END + N'.';
            EXEC dbo.pr_e5_refuser 50855, @m;
        END;
        IF COL_LENGTH(N'dbo.' + QUOTENAME(@t), 'ecartee_le') IS NULL
        BEGIN
            SET @m = N'Écart refusé sur « ' + @lib + N' » : le référentiel ne porte pas les colonnes d’écart « Écartée le », « Écartée par » et « Motif de l’écart ».';
            EXEC dbo.pr_e5_refuser 50855, @m;
        END;
        IF @cle IS NULL
            EXEC dbo.pr_e5_refuser 50839, N'Choisissez la ligne dans la liste « Ligne ».';
        EXEC dbo.pr_e5_resoudre_cle @t, @cle, N'Ligne', N'@k', @clause OUTPUT, @affectation OUTPUT, @k1 OUTPUT, @k2 OUTPUT,
             @canon OUTPUT, @existe OUTPUT, @ligne OUTPUT;
        IF @existe = 0
        BEGIN
            SET @m = N'Écart refusé : la ligne « ' + @cle + N' » n’est pas au référentiel « ' + @lib + N' ».';
            EXEC dbo.pr_e5_refuser 50842, @m;
        END;
        SET @sql = N'SELECT @le = t.[ecartee_le] FROM dbo.' + QUOTENAME(@t) + N' AS t WHERE ' + @clause + N';';
        EXEC sp_executesql @sql, N'@k1 NVARCHAR (400), @k2 NVARCHAR (400), @le DATE OUTPUT', @k1, @k2, @le = @le OUTPUT;
        IF @le IS NOT NULL
        BEGIN
            SET @m = N'Écart refusé : la ligne « ' + @ligne + N' » est écartée depuis le ' + CONVERT(NVARCHAR (10), @le, 103) + N'.';
            EXEC dbo.pr_e5_refuser 50857, @m;
        END;
        -- le champ du formulaire est « Motif » (aide « 600 caracteres au plus ») ; la colonne de la liste, « Motif de
        -- l'ecart » (objet n° 7) ; le contrat n° 14 refuse un motif trop long, il n'exige pas de motif
        IF LEN(@motif) > 600
        BEGIN
            SET @m = N'« Motif » : ' + CAST(LEN(@motif) AS NVARCHAR (12)) + N' caractères, pour 600 au plus.';
            EXEC dbo.pr_e5_refuser 50856, @m;
        END;
        BEGIN TRANSACTION;
        SET @sql = N'UPDATE t SET [ecartee_le] = CAST(SYSUTCDATETIME() AS DATE), [ecartee_par] = @par, [motif_ecart] = @motif FROM dbo.'
                 + QUOTENAME(@t) + N' AS t WHERE ' + @clause + N'; SET @nb = @@ROWCOUNT;';
        EXEC sp_executesql @sql, N'@k1 NVARCHAR (400), @k2 NVARCHAR (400), @par NVARCHAR (400), @motif NVARCHAR (600), @nb INT OUTPUT',
             @k1, @k2, @par, @motif, @nb = @nb OUTPUT;
        SET @message = N'Ligne écartée du référentiel « ' + @lib + N' » le ' + CONVERT(NVARCHAR (10), CAST(SYSUTCDATETIME() AS DATE), 103)
                     + N' : « ' + @ligne + N' ». Elle reste lue par les dossiers qui l’emploient.';
        EXEC dbo.pr_poser_message_ecran @pour = @par, @message = @message, @genre = 'SUCCES', @entite = '-', @procedure_nom = @proc;
        COMMIT TRANSACTION;
        EXEC sp_set_session_context N'par', NULL;
        SELECT CAST('-' AS VARCHAR (20)) AS entite, @message AS message;
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
        SET @e_entite = '-';
        EXEC dbo.pr_e5_conclure_refus @tc, @journal_avant, @proc, @par, @e_entite, @e_journal;
        IF @e_fr IS NOT NULL EXEC dbo.pr_e5_refuser 50868, @e_fr;
        THROW;
    END CATCH;
END;

GO

