-- ------------------------------------------------------------------ n° 12 : ajouter une ligne, copie de la ligne choisie
-- ecran 5, lot 1, script 323 (61_DEPLOIEMENT/generer_e5_323_procedures_de_tenue.py)
-- Contrat de la maquette (objet n° 12, B13, B17, B19) : copie de @modele ; @cle, le code neuf a la forme de la vue (vide
-- pour une cle numerotee) ; raisons de [Blocage ajouter la ligne], dans l'ordre de la maquette : mode TEXTE,
-- action_propre, droit, actions_de_ligne 0, 2 et 3 ; @libelle remplace la valeur copiee de colonne_designation ; une
-- colonne ordre sous unicite recoit le plus grand ordre plus 1, dans le groupe de son index, et celle d'un referentiel
-- de ORDRE_PAR_GROUPE dans son groupe (ref_piece_attendue : cycle ou phase, B13), le groupe compare par INTERSECT ;
-- chaque autre unicite verifiee avant l'ecriture, la colonne nommee ; la designation de la ligne neuve relue apres
-- l'insertion, unique dans le referentiel (B13) ; ref_reference : la reference copiee refusee, intitule de ref_article,
-- citation et lecture sur piece non copiees ; une ligne copiee n'est pas ecartee ; modifie_par = @par et modifie_le sur
-- la ligne inseree.
CREATE   PROCEDURE dbo.pr_ecran_ajouter_ligne_referentiel
    @referentiel NVARCHAR (200) = NULL,
    @modele      NVARCHAR (400) = NULL,
    @cle         NVARCHAR (400) = NULL,
    @libelle     NVARCHAR (MAX) = NULL,
    @par         NVARCHAR (400) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    -- @@TRANCOUNT lu seul, avant toute lecture de table : sous IMPLICIT_TRANSACTIONS (connexion sans autocommit d'une
    -- Data function), la 1re lecture ouvrirait la transaction de l'appelant avant la mesure
    DECLARE @tc INT = @@TRANCOUNT;
    DECLARE @journal_avant INT = ISNULL((SELECT MAX(id) FROM dbo.journal_refus), 0),
            @proc VARCHAR (60) = 'pr_ecran_ajouter_ligne_referentiel', @e_num INT, @e_msg NVARCHAR (2048), @e_fr NVARCHAR (2000),
            @e_journal NVARCHAR (2000), @e_entite VARCHAR (20), @m NVARCHAR (2000), @message NVARCHAR (2000);
    DECLARE @t VARCHAR (120), @lib NVARCHAR (160), @mode VARCHAR (5), @actions TINYINT, @propre NVARCHAR (60), @designation VARCHAR (128),
            @clause_m NVARCHAR (MAX), @aff_m NVARCHAR (MAX), @m1 NVARCHAR (400), @m2 NVARCHAR (400), @canon_m NVARCHAR (400), @ligne_m NVARCHAR (400),
            @clause_k NVARCHAR (MAX), @aff_k NVARCHAR (MAX), @k1 NVARCHAR (400), @k2 NVARCHAR (400), @canon_k NVARCHAR (400), @ligne_k NVARCHAR (400),
            @existe BIT, @oid INT, @numerotee BIT, @pk1 SYSNAME, @pk2 SYSNAME, @lib_d NVARCHAR (128), @type_d SYSNAME, @long_d INT,
            @n_norme VARCHAR (14), @n_ref VARCHAR (20), @intitule NVARCHAR (400), @cols NVARCHAR (MAX), @idx_ordre INT,
            @unicites NVARCHAR (MAX), @sql NVARCHAR (MAX), @doublon SYSNAME, @n INT, @id INT, @noms NVARCHAR (1000), @nb_noms INT,
            @avec_designation BIT, @nl NCHAR (1) = NCHAR (10), @gx NVARCHAR (MAX), @gl NVARCHAR (MAX), @avec_ordre BIT = 0, @nb_d INT;
    SELECT @par = NULLIF(LTRIM(RTRIM(@par)), N''), @modele = NULLIF(LTRIM(RTRIM(@modele)), N''),
           @cle = NULLIF(LTRIM(RTRIM(@cle)), N''), @libelle = NULLIF(LTRIM(RTRIM(@libelle)), N'');
    BEGIN TRY
        IF @par IS NULL
            EXEC dbo.pr_e5_refuser 50830, N'Action refusée : l’auteur de l’action n’est pas transmis ; l’écran le transmet avec l’adresse de connexion de la personne qui clique.';
        EXEC sp_set_session_context N'par', @par;
        EXEC dbo.pr_e5_lire_referentiel @referentiel, @t OUTPUT, @lib OUTPUT, @mode OUTPUT, @actions OUTPUT, @propre OUTPUT, @designation OUTPUT;
        IF @mode = 'TEXTE'
        BEGIN
            SET @m = N'Ajout refusé sur « ' + @lib + N' » : fixé par un texte, non modifiable.';
            EXEC dbo.pr_e5_refuser 50832, @m;
        END;
        IF @propre IS NOT NULL
        BEGIN
            SET @m = N'Ajout refusé sur « ' + @lib + N' » : seuil propre au véhicule, posé par « Enregistrer le seuil du véhicule ».';
            EXEC dbo.pr_e5_refuser 50833, @m;
        END;
        IF dbo.fn_peut_ecrire_referentiel(@t, @par) = 0
        BEGIN
            SET @m = N'Ajout refusé sur « ' + @lib + N' » : aucun droit de modification.';
            EXEC dbo.pr_e5_refuser 50859, @m;
        END;
        IF @actions = 0
        BEGIN
            SET @m = N'Ajout refusé sur « ' + @lib + N' » : seule la valeur se modifie : les codes des paramètres sont fixés par l’outil.';
            EXEC dbo.pr_e5_refuser 50834, @m;
        END;
        IF @actions = 2
        BEGIN
            SET @m = N'Ajout refusé sur « ' + @lib + N' » : un contrôle de cohérence est un calcul programmé dans l’outil, qui ne s’ajoute pas à l’écran.';
            EXEC dbo.pr_e5_refuser 50835, @m;
        END;
        IF @actions = 3
        BEGIN
            SET @m = N'Ajout refusé sur « ' + @lib + N' » : une question de référence s’ajoute à la Révision, ou à l’étape 3 pour une question sur la tenue de la comptabilité.';
            EXEC dbo.pr_e5_refuser 50837, @m;
        END;
        IF @modele IS NULL
            EXEC dbo.pr_e5_refuser 50839, N'Choisissez dans la liste « Ligne » la ligne à copier.';
        EXEC dbo.pr_e5_resoudre_cle @t, @modele, N'Ligne', N'@m', @clause_m OUTPUT, @aff_m OUTPUT, @m1 OUTPUT, @m2 OUTPUT,
             @canon_m OUTPUT, @existe OUTPUT, @ligne_m OUTPUT;
        IF @existe = 0
        BEGIN
            SET @m = N'Ajout refusé : la ligne à copier « ' + @modele + N' » n’est pas au référentiel « ' + @lib + N' ».';
            EXEC dbo.pr_e5_refuser 50842, @m;
        END;
        SET @oid = OBJECT_ID(N'dbo.' + QUOTENAME(@t));
        SELECT @numerotee = CASE WHEN MAX(CAST(c.is_identity AS INT)) = 1 THEN 1 ELSE 0 END,
               @pk1 = MAX(CASE WHEN ic.key_ordinal = 1 THEN c.name END), @pk2 = MAX(CASE WHEN ic.key_ordinal = 2 THEN c.name END)
        FROM sys.indexes i
        JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
        JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
        WHERE i.object_id = @oid AND i.is_primary_key = 1;
        IF @numerotee = 1 AND @cle IS NOT NULL
        BEGIN
            SET @m = N'Ajout refusé sur « ' + @lib + N' » : ligne numérotée automatiquement, sans code ; laissez vide le champ « Code de la nouvelle ligne ».';
            EXEC dbo.pr_e5_refuser 50838, @m;
        END;
        IF @numerotee = 0
        BEGIN
            IF @cle IS NULL
            BEGIN
                SET @m = N'Le champ « Code de la nouvelle ligne » est obligatoire : le code de la ligne à ajouter, de la forme « '
                       + ISNULL(dbo.fn_e5_forme_cle(@t), N'') + N' ».';
                EXEC dbo.pr_e5_refuser 50839, @m;
            END;
            EXEC dbo.pr_e5_resoudre_cle @t, @cle, N'Code de la nouvelle ligne', N'@k', @clause_k OUTPUT, @aff_k OUTPUT, @k1 OUTPUT,
                 @k2 OUTPUT, @canon_k OUTPUT, @existe OUTPUT, @ligne_k OUTPUT;
            IF @existe = 1
            BEGIN
                SET @m = N'Ajout refusé : le code « ' + @canon_k + N' » est déjà celui d’une ligne du référentiel « ' + @lib + N' ».';
                EXEC dbo.pr_e5_refuser 50843, @m;
            END;
            EXEC dbo.pr_e5_controler_reference @t, @pk1, @k1, N'Code de la nouvelle ligne';
            IF @pk2 IS NOT NULL EXEC dbo.pr_e5_controler_reference @t, @pk2, @k2, N'Code de la nouvelle ligne';
        END;
        -- le libelle remplace la valeur copiee de colonne_designation (objet n° 1)
        IF @libelle IS NOT NULL
        BEGIN
            IF @designation IS NULL OR COL_LENGTH(N'dbo.' + QUOTENAME(@t), @designation) IS NULL
            BEGIN
                SET @m = N'Ajout refusé : le référentiel « ' + @lib + N' » n’a pas de libellé ; laissez vide le champ « Libellé ».';
                EXEC dbo.pr_e5_refuser 50853, @m;
            END;
            SELECT @lib_d = dbo.fn_e5_libelle_colonne(@t, c.name), @type_d = TYPE_NAME(c.user_type_id),
                   @long_d = CASE WHEN c.max_length = -1 THEN -1 WHEN TYPE_NAME(c.user_type_id) IN (N'nvarchar', N'nchar') THEN c.max_length / 2
                                  ELSE c.max_length END
            FROM sys.columns c WHERE c.object_id = @oid AND c.name = @designation;
            IF @long_d <> -1 AND LEN(@libelle) > @long_d
            BEGIN
                SET @m = N'« Libellé » : ' + CAST(LEN(@libelle) AS NVARCHAR (10)) + N' caractères, pour ' + CAST(@long_d AS NVARCHAR (10))
                       + N' au plus dans la colonne « ' + @lib_d + N' ».';
                EXEC dbo.pr_e5_refuser 50853, @m;
            END;
            IF @type_d IN (N'varchar', N'char')
               AND CAST(CAST(@libelle AS VARCHAR (MAX)) AS NVARCHAR (MAX)) COLLATE Latin1_General_BIN2 <> @libelle COLLATE Latin1_General_BIN2
            BEGIN
                SET @m = N'« Libellé » : la valeur porte un caractère que la colonne « ' + @lib_d + N' » n’admet pas.';
                EXEC dbo.pr_e5_refuser 50853, @m;
            END;
        END;
        -- ref_reference : une reference neuve, son intitule lu dans ref_article (D29 de l'existant)
        IF @t = 'ref_reference'
        BEGIN
            SELECT @n_norme = r.norme, @n_ref = ISNULL(CAST(@libelle AS VARCHAR (20)), r.reference) FROM dbo.ref_reference r WHERE r.id = CAST(@m1 AS INT);
            IF EXISTS (SELECT 1 FROM dbo.ref_reference r WHERE r.norme = @n_norme AND r.reference = @n_ref)
            BEGIN
                SET @m = N'Ajout refusé : la colonne « ' + dbo.fn_e5_libelle_colonne('ref_reference', 'reference') + N' » porte déjà « ' + @n_ref
                       + N' » pour la norme « ' + @n_norme + N' » ; saisissez au champ « Libellé » la référence neuve.';
                EXEC dbo.pr_e5_refuser 50854, @m;
            END;
            SELECT @intitule = a.intitule FROM dbo.ref_article a WHERE a.article = @n_ref AND a.norme = @n_norme;
            IF NULLIF(LTRIM(RTRIM(@intitule)), N'') IS NULL
            BEGIN
                SET @m = N'Ajout refusé : l’article « ' + @n_ref + N' » de la norme « ' + @n_norme
                       + N' » n’est pas au référentiel des articles avec son intitulé ; aucun intitulé d’article ne se saisit à la main, et la référence s’inscrit avec son article.';
                EXEC dbo.pr_e5_refuser 50850, @m;
            END;
        END;
        -- le lot d'ecriture : la copie dans #l, ses colonnes posees, les unicites relues, puis l'insertion
        SELECT @cols = STRING_AGG(CAST(QUOTENAME(c.name) AS NVARCHAR (MAX)), N', ') WITHIN GROUP (ORDER BY c.column_id)
        FROM sys.columns c WHERE c.object_id = @oid AND c.is_identity = 0 AND c.is_computed = 0;
        SET @sql = N'SELECT * INTO #l FROM dbo.' + QUOTENAME(@t) + N' AS t WHERE ' + @clause_m + N';' + NCHAR (10);
        IF @numerotee = 0 SET @sql += N'UPDATE #l SET ' + @aff_k + N';' + NCHAR (10);
        IF @libelle IS NOT NULL
            SET @sql += N'UPDATE #l SET ' + QUOTENAME(@designation) + N' = CAST(@libelle AS ' + dbo.fn_e5_type_colonne(@t, @designation) + N');' + NCHAR (10);
        IF @t = 'ref_reference'
            SET @sql += N'UPDATE #l SET [intitule] = @intitule, [citation] = NULL, [lu_sur_piece] = 0, [page_piece] = NULL, [piece_reference] = NULL, [lu_le] = NULL;' + NCHAR (10);
        IF COL_LENGTH(N'dbo.' + QUOTENAME(@t), 'ecartee_le') IS NOT NULL
            SET @sql += N'UPDATE #l SET [ecartee_le] = NULL, [ecartee_par] = NULL, [motif_ecart] = NULL;' + NCHAR (10);
        SELECT TOP (1) @idx_ordre = i.index_id
        FROM sys.indexes i
        JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 0
        JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
        WHERE i.object_id = @oid AND i.is_unique = 1 AND c.name = N'ordre';
        -- le groupe de l'ordre : les autres colonnes de l'index unique qui porte ordre ; a defaut, le debut de la
        -- designation (ORDRE_PAR_GROUPE : « cycle ou phase » d'une piece attendue) ; compare par INTERSECT, qui egale
        -- 2 NULL comme un index unique
        IF @idx_ordre IS NOT NULL
        BEGIN
            SELECT @gx = STRING_AGG(CAST(N'x.' + QUOTENAME(c.name) AS NVARCHAR (MAX)), N', ') WITHIN GROUP (ORDER BY ic.key_ordinal),
                   @gl = STRING_AGG(CAST(N'l.' + QUOTENAME(c.name) AS NVARCHAR (MAX)), N', ') WITHIN GROUP (ORDER BY ic.key_ordinal)
            FROM sys.index_columns ic JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
            WHERE ic.object_id = @oid AND ic.index_id = @idx_ordre AND ic.is_included_column = 0 AND c.name <> N'ordre';
            SET @avec_ordre = 1;
        END
        ELSE IF @t = 'ref_piece_attendue' AND COL_LENGTH(N'dbo.' + QUOTENAME(@t), 'ordre') IS NOT NULL
            SELECT @gx = N'COALESCE(NULLIF(x.cycle, N''''), NULLIF(x.phase, N''''), N'''')', @gl = N'COALESCE(NULLIF(l.cycle, N''''), NULLIF(l.phase, N''''), N'''')', @avec_ordre = 1;
        IF @avec_ordre = 1
            SET @sql += N'UPDATE l SET [ordre] = ISNULL((SELECT MAX(x.[ordre]) FROM dbo.' + QUOTENAME(@t) + N' AS x'
                      + ISNULL(N' WHERE EXISTS (SELECT ' + @gx + N' INTERSECT SELECT ' + @gl + N')', N'') + N'), 0) + 1 FROM #l AS l;' + NCHAR (10);
        IF COL_LENGTH(N'dbo.' + QUOTENAME(@t), 'modifie_par') IS NOT NULL SET @sql += N'UPDATE #l SET [modifie_par] = @par;' + NCHAR (10);
        IF COL_LENGTH(N'dbo.' + QUOTENAME(@t), 'modifie_le') IS NOT NULL SET @sql += N'UPDATE #l SET [modifie_le] = SYSUTCDATETIME();' + NCHAR (10);
        SELECT @unicites = STRING_AGG(CAST(N'IF @doublon IS NULL AND EXISTS (SELECT 1 FROM #l AS l JOIN dbo.' + QUOTENAME(@t)
                                           + N' AS x ON EXISTS (SELECT ' + u.cx + N' INTERSECT SELECT ' + u.cl + N')) SET @doublon = N'''
                                           + REPLACE(u.nom, N'''', N'''''') + N''';' AS NVARCHAR (MAX)), @nl)
        FROM (SELECT i.name AS nom,
                     STRING_AGG(CAST(N'x.' + QUOTENAME(c.name) AS NVARCHAR (MAX)), N', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS cx,
                     STRING_AGG(CAST(N'l.' + QUOTENAME(c.name) AS NVARCHAR (MAX)), N', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS cl
              FROM sys.indexes i
              JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 0
              JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
              WHERE i.object_id = @oid AND i.is_unique = 1
                AND NOT EXISTS (SELECT 1 FROM sys.index_columns ic2 JOIN sys.columns c2 ON c2.object_id = ic2.object_id AND c2.column_id = ic2.column_id
                                WHERE ic2.object_id = i.object_id AND ic2.index_id = i.index_id AND c2.is_identity = 1)
              GROUP BY i.index_id, i.name) u;
        SET @sql += ISNULL(@unicites + NCHAR (10), N'')
                  + N'IF @doublon IS NULL BEGIN INSERT INTO dbo.' + QUOTENAME(@t) + N' (' + @cols + N') SELECT ' + @cols
                  + N' FROM #l; SET @n = @@ROWCOUNT; SET @id = SCOPE_IDENTITY(); END;';
        BEGIN TRANSACTION;
        EXEC sp_executesql @sql,
             N'@m1 NVARCHAR (400), @m2 NVARCHAR (400), @k1 NVARCHAR (400), @k2 NVARCHAR (400), @libelle NVARCHAR (MAX), @intitule NVARCHAR (400), @par NVARCHAR (400), @doublon SYSNAME OUTPUT, @n INT OUTPUT, @id INT OUTPUT',
             @m1, @m2, @k1, @k2, @libelle, @intitule, @par, @doublon = @doublon OUTPUT, @n = @n OUTPUT, @id = @id OUTPUT;
        IF @doublon IS NOT NULL
        BEGIN
            -- la colonne nommee : celle que l'ajout pose (code neuf, libelle) dans l'index ; a defaut, toutes ses colonnes
            SELECT @nb_noms = COUNT(*),
                   @noms = STRING_AGG(CAST(N'« ' + dbo.fn_e5_libelle_colonne(@t, c.name) + N' »' AS NVARCHAR (MAX)), N', ') WITHIN GROUP (ORDER BY ic.key_ordinal),
                   @avec_designation = MAX(CASE WHEN c.name = @designation THEN 1 ELSE 0 END)
            FROM sys.indexes i
            JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 0
            JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
            WHERE i.object_id = @oid AND i.name = @doublon
              AND ((c.name = @designation AND @libelle IS NOT NULL) OR (@numerotee = 0 AND c.name IN (@pk1, ISNULL(@pk2, @pk1))));
            IF ISNULL(@nb_noms, 0) = 0
                SELECT @nb_noms = COUNT(*),
                       @noms = STRING_AGG(CAST(N'« ' + dbo.fn_e5_libelle_colonne(@t, c.name) + N' »' AS NVARCHAR (MAX)), N', ') WITHIN GROUP (ORDER BY ic.key_ordinal),
                       @avec_designation = MAX(CASE WHEN c.name = @designation THEN 1 ELSE 0 END)
                FROM sys.indexes i
                JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 0
                JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
                WHERE i.object_id = @oid AND i.name = @doublon;
            SET @m = N'Ajout refusé : ' + CASE WHEN @nb_noms = 1 THEN N'la colonne ' + @noms + N' porte déjà cette valeur'
                                               ELSE N'les colonnes ' + @noms + N' portent déjà ces valeurs' END
                   + N' sur une autre ligne du référentiel « ' + @lib + N' »'
                   + CASE WHEN @avec_designation = 1 THEN N' ; saisissez au champ « Libellé » une valeur neuve.' ELSE N'.' END;
            EXEC dbo.pr_e5_refuser 50854, @m;
        END;
        IF ISNULL(@n, 0) <> 1
        BEGIN
            SET @m = N'Ajout refusé : la ligne à copier « ' + @ligne_m + N' » n’a pas été relue au référentiel « ' + @lib + N' » ; aucune ligne n’est ajoutée.';
            EXEC dbo.pr_e5_refuser 50842, @m;
        END;
        IF @numerotee = 1 SET @canon_k = CAST(@id AS NVARCHAR (12));
        -- la designation de la ligne neuve, unique dans son referentiel (B13) : relue apres l'insertion
        EXEC dbo.pr_e5_designation @t, @canon_k, NULL, @ligne_k OUTPUT, @nb_d OUTPUT;
        IF @nb_d > 1
        BEGIN
            SET @m = N'Ajout refusé : la nouvelle ligne porterait la désignation « ' + @ligne_k + N' », déjà celle d’une autre ligne du référentiel « '
                   + @lib + N' » ; chaque ligne y porte une désignation distincte'
                   + CASE WHEN @designation IS NOT NULL THEN N' ; saisissez au champ « Libellé » une valeur neuve.' ELSE N'.' END;
            EXEC dbo.pr_e5_refuser 50854, @m;
        END;
        SET @message = N'Ligne ajoutée au référentiel « ' + @lib + N' » : « ' + ISNULL(@ligne_k, ISNULL(@libelle, @canon_k)) + N' », copie de « ' + @ligne_m + N' ».';
        EXEC dbo.pr_poser_message_ecran @pour = @par, @message = @message, @genre = 'SUCCES', @entite = '-', @procedure_nom = @proc;
        COMMIT TRANSACTION;
        EXEC sp_set_session_context N'par', NULL;
        SELECT CAST('-' AS VARCHAR (20)) AS entite, @canon_k AS cle, @message AS message;
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

