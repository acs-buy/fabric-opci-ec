-- ------------------------------------------------------------------ n° 13 : changer le code d'une ligne non employee
-- ecran 5, lot 1, script 323 (61_DEPLOIEMENT/generer_e5_323_procedures_de_tenue.py)
-- D9 de l'existant, forme 2 ; raisons de [Blocage changer le code], dans l'ordre de la maquette : mode TEXTE,
-- action_propre, droit, actions_de_ligne 0 et 2, cle numerotee, ligne employee (emploi relu en base, texte employee_par
-- de l'objet n° 6) ; @nouvelle_cle a la forme de @cle de l'objet n° 12 ; la designation relue apres l'ecriture (B13).
CREATE   PROCEDURE dbo.pr_ecran_changer_code_referentiel
    @referentiel  NVARCHAR (200) = NULL,
    @cle          NVARCHAR (400) = NULL,
    @nouvelle_cle NVARCHAR (400) = NULL,
    @par          NVARCHAR (400) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    -- @@TRANCOUNT lu seul, avant toute lecture de table : sous IMPLICIT_TRANSACTIONS (connexion sans autocommit d'une
    -- Data function), la 1re lecture ouvrirait la transaction de l'appelant avant la mesure
    DECLARE @tc INT = @@TRANCOUNT;
    DECLARE @journal_avant INT = ISNULL((SELECT MAX(id) FROM dbo.journal_refus), 0),
            @proc VARCHAR (60) = 'pr_ecran_changer_code_referentiel', @e_num INT, @e_msg NVARCHAR (2048), @e_fr NVARCHAR (2000),
            @e_journal NVARCHAR (2000), @e_entite VARCHAR (20), @m NVARCHAR (2000), @message NVARCHAR (2000);
    DECLARE @t VARCHAR (120), @lib NVARCHAR (160), @mode VARCHAR (5), @actions TINYINT, @propre NVARCHAR (60), @designation VARCHAR (128),
            @clause NVARCHAR (MAX), @affectation NVARCHAR (MAX), @k1 NVARCHAR (400), @k2 NVARCHAR (400), @canon NVARCHAR (400), @ligne NVARCHAR (400),
            @clause_n NVARCHAR (MAX), @aff_n NVARCHAR (MAX), @n1 NVARCHAR (400), @n2 NVARCHAR (400), @canon_n NVARCHAR (400), @ligne_n NVARCHAR (400),
            @existe BIT, @existe_n BIT, @oid INT, @numerotee BIT, @pk1 SYSNAME, @pk2 SYSNAME, @emploi INT, @employee_par NVARCHAR (MAX),
            @sql NVARCHAR (MAX), @nb INT, @ligne_d NVARCHAR (400), @nb_d INT;
    SELECT @par = NULLIF(LTRIM(RTRIM(@par)), N''), @cle = NULLIF(LTRIM(RTRIM(@cle)), N''),
           @nouvelle_cle = NULLIF(LTRIM(RTRIM(@nouvelle_cle)), N'');
    BEGIN TRY
        IF @par IS NULL
            EXEC dbo.pr_e5_refuser 50830, N'Action refusée : l’auteur de l’action n’est pas transmis ; l’écran le transmet avec l’adresse de connexion de la personne qui clique.';
        EXEC sp_set_session_context N'par', @par;
        EXEC dbo.pr_e5_lire_referentiel @referentiel, @t OUTPUT, @lib OUTPUT, @mode OUTPUT, @actions OUTPUT, @propre OUTPUT, @designation OUTPUT;
        IF @mode = 'TEXTE'
        BEGIN
            SET @m = N'Changement de code refusé sur « ' + @lib + N' » : fixé par un texte, non modifiable.';
            EXEC dbo.pr_e5_refuser 50832, @m;
        END;
        IF @propre IS NOT NULL
        BEGIN
            SET @m = N'Changement de code refusé sur « ' + @lib + N' » : seuil propre au véhicule, posé par « Enregistrer le seuil du véhicule ».';
            EXEC dbo.pr_e5_refuser 50833, @m;
        END;
        IF dbo.fn_peut_ecrire_referentiel(@t, @par) = 0
        BEGIN
            SET @m = N'Changement de code refusé sur « ' + @lib + N' » : aucun droit de modification.';
            EXEC dbo.pr_e5_refuser 50859, @m;
        END;
        IF @actions = 0
        BEGIN
            SET @m = N'Changement de code refusé sur « ' + @lib + N' » : seule la valeur se modifie : les codes des paramètres sont fixés par l’outil.';
            EXEC dbo.pr_e5_refuser 50834, @m;
        END;
        IF @actions = 2
        BEGIN
            SET @m = N'Changement de code refusé sur « ' + @lib + N' » : le code d’un contrôle est la colonne « Code », modifiée par « Modifier la valeur ».';
            EXEC dbo.pr_e5_refuser 50836, @m;
        END;
        SET @oid = OBJECT_ID(N'dbo.' + QUOTENAME(@t));
        SELECT @numerotee = CASE WHEN MAX(CAST(c.is_identity AS INT)) = 1 THEN 1 ELSE 0 END,
               @pk1 = MAX(CASE WHEN ic.key_ordinal = 1 THEN c.name END), @pk2 = MAX(CASE WHEN ic.key_ordinal = 2 THEN c.name END)
        FROM sys.indexes i
        JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
        JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
        WHERE i.object_id = @oid AND i.is_primary_key = 1;
        IF @numerotee = 1
        BEGIN
            SET @m = N'Changement de code refusé sur « ' + @lib + N' » : ligne numérotée automatiquement, sans code.';
            EXEC dbo.pr_e5_refuser 50838, @m;
        END;
        IF @cle IS NULL
            EXEC dbo.pr_e5_refuser 50839, N'Choisissez la ligne dans la liste « Ligne ».';
        EXEC dbo.pr_e5_resoudre_cle @t, @cle, N'Ligne', N'@k', @clause OUTPUT, @affectation OUTPUT, @k1 OUTPUT, @k2 OUTPUT,
             @canon OUTPUT, @existe OUTPUT, @ligne OUTPUT;
        IF @existe = 0
        BEGIN
            SET @m = N'Changement de code refusé : la ligne « ' + @cle + N' » n’est pas au référentiel « ' + @lib + N' ».';
            EXEC dbo.pr_e5_refuser 50842, @m;
        END;
        EXEC dbo.pr_e5_emploi @t, @clause, @k1, @k2, @canon, @cle, @emploi OUTPUT, @employee_par OUTPUT;
        IF @emploi > 0
        BEGIN
            SET @m = N'Changement de code refusé : ligne employée par ' + @employee_par + N', elle garde son code.';
            EXEC dbo.pr_e5_refuser 50844, @m;
        END;
        IF @nouvelle_cle IS NULL
        BEGIN
            SET @m = N'Le champ « Nouveau code » est obligatoire : le code que prend la ligne « ' + @ligne + N' », de la forme « '
                   + ISNULL(dbo.fn_e5_forme_cle(@t), N'') + N' ».';
            EXEC dbo.pr_e5_refuser 50858, @m;
        END;
        EXEC dbo.pr_e5_resoudre_cle @t, @nouvelle_cle, N'Nouveau code', N'@n', @clause_n OUTPUT, @aff_n OUTPUT, @n1 OUTPUT, @n2 OUTPUT,
             @canon_n OUTPUT, @existe_n OUTPUT, @ligne_n OUTPUT;
        IF @canon_n COLLATE Latin1_General_BIN2 = @canon COLLATE Latin1_General_BIN2
        BEGIN
            SET @m = N'Changement de code refusé : « ' + @canon_n + N' » est déjà le code de la ligne.';
            EXEC dbo.pr_e5_refuser 50858, @m;
        END;
        IF @existe_n = 1 AND @canon_n <> @canon
        BEGIN
            SET @m = N'Changement de code refusé : le code « ' + @canon_n + N' » est déjà celui d’une autre ligne du référentiel « ' + @lib + N' ».';
            EXEC dbo.pr_e5_refuser 50843, @m;
        END;
        IF @n1 <> @k1 EXEC dbo.pr_e5_controler_reference @t, @pk1, @n1, N'Nouveau code';
        IF @pk2 IS NOT NULL AND @n2 <> @k2 EXEC dbo.pr_e5_controler_reference @t, @pk2, @n2, N'Nouveau code';
        BEGIN TRANSACTION;
        SET @sql = N'UPDATE t SET ' + @aff_n + N' FROM dbo.' + QUOTENAME(@t) + N' AS t WHERE ' + @clause + N'; SET @nb = @@ROWCOUNT;';
        EXEC sp_executesql @sql, N'@k1 NVARCHAR (400), @k2 NVARCHAR (400), @n1 NVARCHAR (400), @n2 NVARCHAR (400), @nb INT OUTPUT',
             @k1, @k2, @n1, @n2, @nb = @nb OUTPUT;
        -- la designation de la ligne reste unique dans son referentiel (B13) : relue apres l'ecriture ; une designation
        -- inchangee ne se refuse pas (un doublon anterieur ne vient pas de cette ecriture)
        EXEC dbo.pr_e5_designation @t, @canon_n, @nouvelle_cle, @ligne_d OUTPUT, @nb_d OUTPUT;
        IF @nb_d > 1 AND @ligne_d <> @ligne
        BEGIN
            SET @m = N'Changement de code refusé : avec le code « ' + @canon_n + N' », la ligne « ' + @ligne + N' » porterait la désignation « '
                   + @ligne_d + N' », déjà celle d’une autre ligne du référentiel « ' + @lib + N' » ; chaque ligne y porte une désignation distincte.';
            EXEC dbo.pr_e5_refuser 50854, @m;
        END;
        SET @message = N'Code changé dans le référentiel « ' + @lib + N' » : la ligne « ' + @ligne + N' » prend le code « ' + @canon_n + N' ».';
        EXEC dbo.pr_poser_message_ecran @pour = @par, @message = @message, @genre = 'SUCCES', @entite = '-', @procedure_nom = @proc;
        COMMIT TRANSACTION;
        EXEC sp_set_session_context N'par', NULL;
        SELECT CAST('-' AS VARCHAR (20)) AS entite, @canon_n AS cle, @message AS message;
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

