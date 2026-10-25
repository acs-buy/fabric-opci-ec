
-- ===================================================================== 2. LES 6 PROCEDURES
-- ------------------------------------------------------------------ n° 11 : modifier la valeur d'une cellule
-- ecran 5, lot 1, script 323 (61_DEPLOIEMENT/generer_e5_323_procedures_de_tenue.py)
-- Contrat de la maquette (objet n° 11) ; raisons de [Blocage modifier la valeur], dans l'ordre de la maquette : mode
-- TEXTE, action_propre, droit, colonne non modifiable de la liste (une colonne de la liste que la table ne porte pas
-- comprise), lecture_seule (adresse d'installation) ; puis le contrat seul : colonne d'un parametre autre que la valeur ;
-- une colonne de la cle se change par « Changer le code » ; libelle d'enumeration traduit en code par ref_libelle_valeur ;
-- « Reference » recue en « norme reference » ; ref_reference : une norme ou une reference neuve recopie l'intitule de
-- ref_article et vide citation et lecture sur piece ; ref_parametre : la valeur d'un SEUIL seul, entier positif ou nul.
-- Une valeur inchangee ne s'ecrit pas. La designation de la ligne, relue apres l'ecriture, reste unique (B13).
CREATE   PROCEDURE dbo.pr_ecran_modifier_valeur_referentiel
    @referentiel NVARCHAR (200) = NULL,
    @cle         NVARCHAR (400) = NULL,
    @colonne     NVARCHAR (200) = NULL,
    @valeur      NVARCHAR (MAX) = NULL,
    @par         NVARCHAR (400) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    -- @@TRANCOUNT lu seul, avant toute lecture de table : sous IMPLICIT_TRANSACTIONS (connexion sans autocommit d'une
    -- Data function), la 1re lecture ouvrirait la transaction de l'appelant avant la mesure
    DECLARE @tc INT = @@TRANCOUNT;
    DECLARE @journal_avant INT = ISNULL((SELECT MAX(id) FROM dbo.journal_refus), 0),
            @proc VARCHAR (60) = 'pr_ecran_modifier_valeur_referentiel', @e_num INT, @e_msg NVARCHAR (2048), @e_fr NVARCHAR (2000),
            @e_journal NVARCHAR (2000), @e_entite VARCHAR (20), @m NVARCHAR (2000), @message NVARCHAR (2000);
    DECLARE @t VARCHAR (120), @lib NVARCHAR (160), @mode VARCHAR (5), @actions TINYINT, @propre NVARCHAR (60), @designation VARCHAR (128),
            @clause NVARCHAR (MAX), @affectation NVARCHAR (MAX), @k1 NVARCHAR (400), @k2 NVARCHAR (400), @canon NVARCHAR (400),
            @existe BIT, @ligne NVARCHAR (400), @oid INT, @col SYSNAME, @lib_col NVARCHAR (128), @type_nom SYSNAME, @type NVARCHAR (60),
            @longueur INT, @precision INT, @echelle INT, @nullable BIT, @identite BIT, @calculee BIT, @dans_cle BIT, @modifiable BIT,
            @v NVARCHAR (MAX), @affiche NVARCHAR (MAX), @d DECIMAL (38, 10), @dt DATE, @code_enum NVARCHAR (30), @lib_enum NVARCHAR (60),
            @admises NVARCHAR (MAX), @expr NVARCHAR (200), @extra NVARCHAR (400) = N'', @intitule NVARCHAR (400),
            @n_norme VARCHAR (14), @n_ref VARCHAR (20), @sql NVARCHAR (MAX), @n INT, @fk_cible SYSNAME, @fk_col SYSNAME,
            @installation BIT, @col_vue SYSNAME, @lib_vue NVARCHAR (200), @ligne_n NVARCHAR (400), @nb_d INT;
    SELECT @par = NULLIF(LTRIM(RTRIM(@par)), N''), @cle = NULLIF(LTRIM(RTRIM(@cle)), N''),
           @colonne = NULLIF(LTRIM(RTRIM(@colonne)), N''), @valeur = NULLIF(LTRIM(RTRIM(@valeur)), N'');
    BEGIN TRY
        IF @par IS NULL
            EXEC dbo.pr_e5_refuser 50830, N'Action refusée : l’auteur de l’action n’est pas transmis ; l’écran le transmet avec l’adresse de connexion de la personne qui clique.';
        EXEC sp_set_session_context N'par', @par;
        EXEC dbo.pr_e5_lire_referentiel @referentiel, @t OUTPUT, @lib OUTPUT, @mode OUTPUT, @actions OUTPUT, @propre OUTPUT, @designation OUTPUT;
        IF @mode = 'TEXTE'
        BEGIN
            SET @m = N'Modification refusée sur « ' + @lib + N' » : fixé par un texte, non modifiable.';
            EXEC dbo.pr_e5_refuser 50832, @m;
        END;
        IF @propre IS NOT NULL
        BEGIN
            SET @m = N'Modification refusée sur « ' + @lib + N' » : seuil propre au véhicule, posé par « Enregistrer le seuil du véhicule ».';
            EXEC dbo.pr_e5_refuser 50833, @m;
        END;
        IF dbo.fn_peut_ecrire_referentiel(@t, @par) = 0
        BEGIN
            SET @m = N'Modification refusée sur « ' + @lib + N' » : aucun droit de modification.';
            EXEC dbo.pr_e5_refuser 50859, @m;
        END;
        IF @cle IS NULL
            EXEC dbo.pr_e5_refuser 50839, N'Choisissez la ligne dans la liste « Ligne ».';
        EXEC dbo.pr_e5_resoudre_cle @t, @cle, N'Ligne', N'@k', @clause OUTPUT, @affectation OUTPUT, @k1 OUTPUT, @k2 OUTPUT,
             @canon OUTPUT, @existe OUTPUT, @ligne OUTPUT;
        IF @existe = 0
        BEGIN
            SET @m = N'Modification refusée : la ligne « ' + @cle + N' » n’est pas au référentiel « ' + @lib + N' ».';
            EXEC dbo.pr_e5_refuser 50842, @m;
        END;
        -- l'adresse d'installation (lecture_seule de la ligne) : refusee ici sans colonne choisie, apres la colonne sinon,
        -- [Blocage modifier la valeur] rendant RAISON_COLONNE pour une colonne non modifiable de toute ligne
        SET @installation = CASE WHEN @t = 'ref_parametre' AND ISNULL(dbo.fn_e5_genre_parametre(@k1), '') <> 'SEUIL' THEN 1 ELSE 0 END;
        IF @colonne IS NULL
        BEGIN
            IF @installation = 1
            BEGIN
                SET @m = N'Modification refusée sur « ' + @ligne + N' » : adresse d’installation, non modifiable.';
                EXEC dbo.pr_e5_refuser 50847, @m;
            END;
            EXEC dbo.pr_e5_refuser 50845, N'Choisissez la colonne dans la liste « Colonne ».';
        END;
        -- la colonne se recoit par son nom dans la table, ou par son nom ou son libelle dans la liste (segment
        -- « Colonne », v_ecran_referentiel_colonnes), ou par un libelle de ref_libelle_colonne
        SET @oid = OBJECT_ID(N'dbo.' + QUOTENAME(@t));
        SELECT @col = c.name FROM sys.columns c WHERE c.object_id = @oid AND c.name = @colonne;
        IF OBJECT_ID(N'dbo.v_ecran_referentiel_colonnes') IS NOT NULL
            SELECT TOP (1) @col_vue = vc.colonne, @lib_vue = vc.libelle_colonne, @modifiable = vc.modifiable
            FROM dbo.v_ecran_referentiel_colonnes vc
            WHERE vc.referentiel = @t AND (vc.colonne = ISNULL(@col, @colonne) OR (@col IS NULL AND vc.libelle_colonne = @colonne))
            ORDER BY CASE WHEN vc.colonne = ISNULL(@col, @colonne) THEN 0 ELSE 1 END
            OPTION (RECOMPILE);
        IF @col IS NULL AND @col_vue IS NOT NULL
            SELECT @col = c.name FROM sys.columns c WHERE c.object_id = @oid AND c.name = @col_vue;
        IF @col IS NULL AND @col_vue IS NULL
            SELECT TOP (1) @col = c.name FROM sys.columns c
            JOIN dbo.ref_libelle_colonne l ON l.colonne = c.name COLLATE DATABASE_DEFAULT AND l.vue IN (@t, '*')
            WHERE c.object_id = @oid AND l.libelle = @colonne
            ORDER BY CASE WHEN l.vue = @t THEN 0 ELSE 1 END;
        IF @col IS NULL AND @col_vue IS NULL
        BEGIN
            SET @m = N'Modification refusée : « ' + @colonne + N' » n’est pas une colonne du référentiel « ' + @lib + N' ».';
            EXEC dbo.pr_e5_refuser 50845, @m;
        END;
        -- une colonne de la liste que la table ne porte pas (« Employée par », l'horodatage des parametres) : calculee
        IF @col IS NULL
        BEGIN
            SET @m = N'Modification refusée sur « ' + ISNULL(@lib_vue, @colonne) + N' » : colonne calculée ou citation d’un texte.';
            EXEC dbo.pr_e5_refuser 50846, @m;
        END;
        SET @lib_col = dbo.fn_e5_libelle_colonne(@t, @col);
        -- contrat n° 11 : des parametres du cabinet, seule la valeur se modifie ; toute autre colonne de la table (code,
        -- libelle, description, genre, pose_par, pose_le) se refuse ici en 50834, des qu'elle est reconnue, avant les
        -- refus 50846 et l'adresse d'installation qui suivent ; l'ordre des autres referentiels ne change pas
        IF @t = 'ref_parametre' AND @col <> 'valeur'
        BEGIN
            SET @m = N'Modification refusée sur « ' + @lib_col + N' » : seule la valeur se modifie : les codes des paramètres sont fixés par l’outil.';
            EXEC dbo.pr_e5_refuser 50834, @m;
        END;
        SELECT @type_nom = TYPE_NAME(c.user_type_id),
               @longueur = CASE WHEN c.max_length = -1 THEN -1 WHEN TYPE_NAME(c.user_type_id) IN (N'nvarchar', N'nchar') THEN c.max_length / 2
                                ELSE c.max_length END,
               @precision = c.precision, @echelle = c.scale, @nullable = c.is_nullable, @identite = c.is_identity,
               @calculee = c.is_computed,
               @dans_cle = CASE WHEN EXISTS (SELECT 1 FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id = i.object_id
                                             AND ic.index_id = i.index_id WHERE i.object_id = @oid AND i.is_primary_key = 1
                                             AND ic.column_id = c.column_id) THEN 1 ELSE 0 END
        FROM sys.columns c WHERE c.object_id = @oid AND c.name = @col;
        IF @identite = 1
        BEGIN
            SET @m = N'Modification refusée sur « ' + @lib_col + N' » : ligne numérotée automatiquement, sans code.';
            EXEC dbo.pr_e5_refuser 50846, @m;
        END;
        IF @dans_cle = 1
        BEGIN
            SET @m = N'Modification refusée : « ' + @lib_col + N' » fait partie du code de la ligne, qui se change par « Changer le code ».';
            EXEC dbo.pr_e5_refuser 50846, @m;
        END;
        IF @col IN ('ecartee_le', 'ecartee_par', 'motif_ecart')
        BEGIN
            SET @m = N'Modification refusée : « ' + @lib_col + N' » se pose par « Écarter la ligne ».';
            EXEC dbo.pr_e5_refuser 50846, @m;
        END;
        IF @type_nom IS NULL OR @calculee = 1 OR @col IN ('modifie_par', 'modifie_le', 'pose_par', 'pose_le') OR ISNULL(@modifiable, 1) = 0
           OR (@t = 'ref_reference' AND @col IN ('intitule', 'citation'))
           OR @type_nom NOT IN (N'tinyint', N'smallint', N'int', N'bigint', N'decimal', N'numeric', N'bit', N'date',
                                N'varchar', N'char', N'nvarchar', N'nchar')
        BEGIN
            SET @m = N'Modification refusée sur « ' + @lib_col + N' » : colonne calculée ou citation d’un texte.';
            EXEC dbo.pr_e5_refuser 50846, @m;
        END;
        IF @installation = 1
        BEGIN
            SET @m = N'Modification refusée sur « ' + @ligne + N' » : adresse d’installation, non modifiable.';
            EXEC dbo.pr_e5_refuser 50847, @m;
        END;
        SET @type = dbo.fn_e5_type_colonne(@t, @col);
        SET @affiche = @valeur;
        -- la cle etrangere d'une colonne : une reference normative se saisit « norme reference » (contrat n° 11), une
        -- question de reference par sa reference (B13), un sujet des questions sur la tenue par son libelle (B14), comme
        -- la liste les montre
        SELECT TOP (1) @fk_cible = OBJECT_NAME(fk.referenced_object_id), @fk_col = rc.name
        FROM sys.foreign_keys fk
        JOIN sys.foreign_key_columns fc ON fc.constraint_object_id = fk.object_id
        JOIN sys.columns pc ON pc.object_id = fc.parent_object_id AND pc.column_id = fc.parent_column_id
        JOIN sys.columns rc ON rc.object_id = fc.referenced_object_id AND rc.column_id = fc.referenced_column_id
        WHERE fk.parent_object_id = @oid AND pc.name = @col
          AND NOT EXISTS (SELECT 1 FROM sys.foreign_key_columns f2 WHERE f2.constraint_object_id = fk.object_id AND f2.constraint_column_id > 1);
        -- un seuil des parametres du cabinet : un nombre entier positif ou nul (objet n° 11)
        IF @t = 'ref_parametre'
        BEGIN
            IF @valeur IS NULL OR @valeur LIKE N'%[^0-9]%' OR LEN(@valeur) > 9
            BEGIN
                SET @m = N'« Nouvelle valeur » : un seuil des paramètres du cabinet est un nombre entier positif ou nul'
                       + CASE WHEN @valeur IS NULL THEN N', et le champ est vide.' ELSE N', et « ' + @valeur + N' » n’en est pas un.' END;
                EXEC dbo.pr_e5_refuser 50852, @m;
            END;
            SELECT @valeur = CAST(CAST(@valeur AS INT) AS NVARCHAR (12)), @affiche = CAST(CAST(@valeur AS INT) AS NVARCHAR (12));
        END;
        -- la valeur : un libelle d'enumeration se traduit en code (ref_libelle_valeur, objet n° 8)
        IF @valeur IS NOT NULL AND EXISTS (SELECT 1 FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = @t AND lv.colonne = @col)
        BEGIN
            SELECT TOP (1) @code_enum = lv.valeur, @lib_enum = lv.libelle FROM dbo.ref_libelle_valeur lv
            WHERE lv.table_nom = @t AND lv.colonne = @col AND (lv.libelle = @valeur OR lv.valeur = @valeur)
            ORDER BY CASE WHEN lv.libelle = @valeur THEN 0 ELSE 1 END;
            IF @code_enum IS NULL
            BEGIN
                SELECT @admises = STRING_AGG(CAST(N'« ' + lv.libelle + N' »' AS NVARCHAR (MAX)), N', ') WITHIN GROUP (ORDER BY lv.libelle)
                FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = @t AND lv.colonne = @col;
                SET @m = N'« Nouvelle valeur » : « ' + @valeur + N' » n’est pas une valeur admise de la colonne « ' + @lib_col
                       + N' » ; valeurs admises : ' + ISNULL(@admises, N'') + N'.';
                EXEC dbo.pr_e5_refuser 50848, @m;
            END;
            SELECT @valeur = @code_enum, @affiche = @lib_enum;
        END;
        IF @valeur IS NULL
        BEGIN
            IF @nullable = 0
            BEGIN
                SET @m = N'Le champ « Nouvelle valeur » est vide, et la colonne « ' + @lib_col + N' » ne reste pas vide.';
                EXEC dbo.pr_e5_refuser 50849, @m;
            END;
            SET @v = NULL;
        END
        ELSE IF @fk_cible = N'ref_reference' AND @fk_col = N'id'
        BEGIN
            SELECT TOP (1) @v = CAST(r.id AS NVARCHAR (12)), @affiche = r.norme + N' ' + r.reference FROM dbo.ref_reference r
            WHERE r.norme + N' ' + r.reference = @valeur OR (@valeur NOT LIKE N'%[^0-9]%' AND LEN(@valeur) <= 9 AND r.id = TRY_CAST(@valeur AS INT))
            ORDER BY CASE WHEN r.norme + N' ' + r.reference = @valeur THEN 0 ELSE 1 END;
            IF @v IS NULL
            BEGIN
                SET @m = N'« Nouvelle valeur » : « ' + @valeur + N' » n’est pas une référence normative ; la colonne « ' + @lib_col
                       + N' » se saisit « norme référence », comme « '
                       + ISNULL((SELECT TOP (1) r.norme + N' ' + r.reference FROM dbo.ref_reference r ORDER BY r.id), N'') + N' ».';
                EXEC dbo.pr_e5_refuser 50850, @m;
            END;
        END
        ELSE IF @fk_cible = N'ref_question' AND @fk_col = N'id'
        BEGIN
            SELECT TOP (1) @v = CAST(q.id AS NVARCHAR (12)), @affiche = q.reference FROM dbo.ref_question q
            WHERE q.reference = @valeur OR (@valeur NOT LIKE N'%[^0-9]%' AND LEN(@valeur) <= 9 AND q.id = TRY_CAST(@valeur AS INT))
            ORDER BY CASE WHEN q.reference = @valeur THEN 0 ELSE 1 END;
            IF @v IS NULL
            BEGIN
                SET @m = N'« Nouvelle valeur » : « ' + @valeur + N' » n’est pas une question de référence ; la colonne « ' + @lib_col
                       + N' » se saisit par la référence de la question, comme « '
                       + ISNULL((SELECT TOP (1) q.reference FROM dbo.ref_question q ORDER BY q.id), N'') + N' ».';
                EXEC dbo.pr_e5_refuser 50850, @m;
            END;
        END
        ELSE IF @fk_cible IN (N'ref_sujet_tenue') AND @fk_col = N'code'
        BEGIN
            -- B14 : un sujet des questions sur la tenue se designe par son libelle, unique (objet n° 34), que la liste
            -- rend a la place du code ; la colonne le recoit, ou le code, et enregistre le code
            SET @sql = N'SELECT TOP (1) @v = CAST(x.[code] AS NVARCHAR (MAX)), @affiche = CAST(x.[libelle] AS NVARCHAR (MAX)) FROM dbo.'
                     + QUOTENAME(@fk_cible) + N' AS x WHERE x.[libelle] = @valeur OR CAST(x.[code] AS NVARCHAR (MAX)) = @valeur'
                     + N' ORDER BY CASE WHEN x.[libelle] = @valeur THEN 0 ELSE 1 END;';
            EXEC sp_executesql @sql, N'@valeur NVARCHAR (MAX), @v NVARCHAR (MAX) OUTPUT, @affiche NVARCHAR (MAX) OUTPUT',
                 @valeur, @v = @v OUTPUT, @affiche = @affiche OUTPUT;
            IF @v IS NULL
            BEGIN
                SET @sql = N'SELECT TOP (1) @affiche = CAST(x.[libelle] AS NVARCHAR (MAX)) FROM dbo.' + QUOTENAME(@fk_cible)
                         + N' AS x ORDER BY x.[code];';
                EXEC sp_executesql @sql, N'@affiche NVARCHAR (MAX) OUTPUT', @affiche = @affiche OUTPUT;
                SET @m = N'« Nouvelle valeur » : « ' + @valeur + N' » n’est pas une ligne du référentiel « ' + dbo.fn_e5_libelle_referentiel(@fk_cible)
                       + N' » ; la colonne « ' + @lib_col + N' » se saisit par son libellé, comme « ' + ISNULL(@affiche, N'') + N' ».';
                EXEC dbo.pr_e5_refuser 50850, @m;
            END;
        END
        ELSE IF @type_nom IN (N'tinyint', N'smallint', N'int', N'bigint')
        BEGIN
            SET @d = dbo.fn_e5_nombre(@valeur);
            IF @d IS NULL OR @d <> ROUND(@d, 0)
               OR @d < CASE @type_nom WHEN N'tinyint' THEN 0 WHEN N'smallint' THEN -32768 WHEN N'int' THEN -2147483648 ELSE -9223372036854775808 END
               OR @d > CASE @type_nom WHEN N'tinyint' THEN 255 WHEN N'smallint' THEN 32767 WHEN N'int' THEN 2147483647 ELSE 9223372036854775807 END
            BEGIN
                SET @m = N'« Nouvelle valeur » : « ' + @valeur + N' » n’est pas un nombre entier que la colonne « ' + @lib_col + N' » admet.';
                EXEC dbo.pr_e5_refuser 50849, @m;
            END;
            SET @v = CAST(CAST(@d AS BIGINT) AS NVARCHAR (20));
        END
        ELSE IF @type_nom IN (N'decimal', N'numeric')
        BEGIN
            SET @d = dbo.fn_e5_nombre(@valeur);
            IF @d IS NULL
            BEGIN
                SET @m = N'« Nouvelle valeur » : « ' + @valeur + N' » n’est pas un nombre, et la colonne « ' + @lib_col + N' » en attend un.';
                EXEC dbo.pr_e5_refuser 50849, @m;
            END;
            IF @d <> ROUND(@d, @echelle) OR ABS(@d) >= POWER(CAST(10 AS DECIMAL (38, 0)), @precision - @echelle)
            BEGIN
                SET @m = N'« Nouvelle valeur » : « ' + @valeur + N' » dépasse la colonne « ' + @lib_col + N' », qui porte au plus '
                       + CAST(@precision - @echelle AS NVARCHAR (4)) + N' chiffres avant la virgule et ' + CAST(@echelle AS NVARCHAR (4)) + N' après.';
                EXEC dbo.pr_e5_refuser 50849, @m;
            END;
            SET @v = CAST(@d AS NVARCHAR (60));
        END
        ELSE IF @type_nom = N'bit'
        BEGIN
            SET @v = CASE WHEN @valeur IN (N'1', N'oui', N'vrai') THEN N'1' WHEN @valeur IN (N'0', N'non', N'faux') THEN N'0' END;
            IF @v IS NULL
            BEGIN
                SET @m = N'« Nouvelle valeur » : « ' + @valeur + N' » n’est pas une valeur admise de la colonne « ' + @lib_col
                       + N' » ; valeurs admises : « oui », « non ».';
                EXEC dbo.pr_e5_refuser 50849, @m;
            END;
        END
        ELSE IF @type_nom = N'date'
        BEGIN
            SET @dt = dbo.fn_e5_date(@valeur);
            IF @dt IS NULL
            BEGIN
                SET @m = N'« Nouvelle valeur » : « ' + @valeur + N' » n’est pas une date jj/mm/aaaa, que la colonne « ' + @lib_col + N' » attend.';
                EXEC dbo.pr_e5_refuser 50849, @m;
            END;
            SET @v = CONVERT(NVARCHAR (10), @dt, 23);
        END
        ELSE
        BEGIN
            IF @longueur <> -1 AND LEN(@valeur) > @longueur
            BEGIN
                SET @m = N'« Nouvelle valeur » : ' + CAST(LEN(@valeur) AS NVARCHAR (10)) + N' caractères, pour ' + CAST(@longueur AS NVARCHAR (10))
                       + N' au plus dans la colonne « ' + @lib_col + N' ».';
                EXEC dbo.pr_e5_refuser 50849, @m;
            END;
            IF @type_nom IN (N'varchar', N'char')
               AND CAST(CAST(@valeur AS VARCHAR (MAX)) AS NVARCHAR (MAX)) COLLATE Latin1_General_BIN2 <> @valeur COLLATE Latin1_General_BIN2
            BEGIN
                SET @m = N'« Nouvelle valeur » porte un caractère que la colonne « ' + @lib_col + N' » n’admet pas.';
                EXEC dbo.pr_e5_refuser 50849, @m;
            END;
            SET @v = @valeur;
        END;
        IF NOT (ISNULL(@fk_cible, N'') IN (N'ref_reference', N'ref_question') AND ISNULL(@fk_col, N'') = N'id')
           AND NOT (ISNULL(@fk_cible, N'') IN (N'ref_sujet_tenue') AND ISNULL(@fk_col, N'') = N'code')
            EXEC dbo.pr_e5_controler_reference @t, @col, @v, N'Nouvelle valeur';
        -- ref_reference : une norme ou une reference neuve recopie l'intitule de l'article (D29 de l'existant)
        IF @t = 'ref_reference' AND @col IN ('norme', 'reference')
        BEGIN
            SELECT @n_norme = CASE WHEN @col = 'norme' THEN CAST(@v AS VARCHAR (14)) ELSE r.norme END,
                   @n_ref = CASE WHEN @col = 'reference' THEN CAST(@v AS VARCHAR (20)) ELSE r.reference END
            FROM dbo.ref_reference r WHERE r.id = CAST(@k1 AS INT);
            SELECT @intitule = a.intitule FROM dbo.ref_article a WHERE a.article = @n_ref AND a.norme = @n_norme;
            IF NULLIF(LTRIM(RTRIM(@intitule)), N'') IS NULL
            BEGIN
                SET @m = N'Modification refusée : l’article « ' + ISNULL(@n_ref, N'') + N' » de la norme « ' + ISNULL(@n_norme, N'')
                       + N' » n’est pas au référentiel des articles avec son intitulé ; aucun intitulé d’article ne se saisit à la main.';
                EXEC dbo.pr_e5_refuser 50850, @m;
            END;
            SET @extra = N', [intitule] = @intitule, [citation] = NULL, [lu_sur_piece] = 0, [page_piece] = NULL, [piece_reference] = NULL, [lu_le] = NULL';
        END;
        SET @affiche = CASE WHEN @affiche IS NULL THEN N'vide' WHEN LEN(@affiche) > 120 THEN LEFT(@affiche, 119) + N'…' ELSE @affiche END;
        SET @expr = CASE WHEN @v IS NULL THEN N'CAST(NULL AS ' + @type + N')' ELSE N'CAST(@v AS ' + @type + N')' END;
        -- une valeur inchangee ne s'ecrit pas : ni modifie_par, ni modifie_le ne bougent
        SET @sql = N'SELECT @n = COUNT(*) FROM dbo.' + QUOTENAME(@t) + N' AS t WHERE ' + @clause
                 + N' AND EXISTS (SELECT t.' + QUOTENAME(@col) + N' INTERSECT SELECT ' + @expr + N');';
        EXEC sp_executesql @sql, N'@k1 NVARCHAR (400), @k2 NVARCHAR (400), @v NVARCHAR (MAX), @n INT OUTPUT', @k1, @k2, @v, @n = @n OUTPUT;
        IF @n > 0
        BEGIN
            SET @message = N'Aucune modification : « ' + @lib_col + N' » de la ligne « ' + @ligne + N' » vaut déjà « ' + @affiche + N' ».';
            EXEC dbo.pr_poser_message_ecran @pour = @par, @message = @message, @genre = 'SUCCES', @entite = '-', @procedure_nom = @proc;
            EXEC sp_set_session_context N'par', NULL;
            SELECT CAST('-' AS VARCHAR (20)) AS entite, @message AS message;
            RETURN;
        END;
        BEGIN TRANSACTION;
        SET @sql = N'UPDATE t SET ' + QUOTENAME(@col) + N' = ' + @expr + @extra + N' FROM dbo.' + QUOTENAME(@t) + N' AS t WHERE '
                 + @clause + N'; SET @n = @@ROWCOUNT;';
        EXEC sp_executesql @sql, N'@k1 NVARCHAR (400), @k2 NVARCHAR (400), @v NVARCHAR (MAX), @intitule NVARCHAR (400), @n INT OUTPUT',
             @k1, @k2, @v, @intitule, @n = @n OUTPUT;
        -- la designation de la ligne reste unique dans son referentiel (B13) : relue apres l'ecriture ; une designation
        -- inchangee ne se refuse pas (un doublon anterieur, que le controle C8 releve, ne vient pas de cette ecriture)
        EXEC dbo.pr_e5_designation @t, @canon, @cle, @ligne_n OUTPUT, @nb_d OUTPUT;
        IF @nb_d > 1 AND @ligne_n <> @ligne
        BEGIN
            SET @m = N'« Nouvelle valeur » : « ' + @affiche + N' » donnerait à la ligne « ' + @ligne + N' » la désignation « ' + @ligne_n
                   + N' », déjà celle d’une autre ligne du référentiel « ' + @lib + N' » ; chaque ligne y porte une désignation distincte.';
            EXEC dbo.pr_e5_refuser 50854, @m;
        END;
        SET @message = N'Valeur enregistrée : « ' + @lib_col + N' » de la ligne « ' + @ligne + N' » (' + @lib + N') vaut « ' + @affiche + N' ».'
                     + CASE WHEN @extra <> N'' THEN N' L’intitulé est repris du référentiel des articles ; la citation et la lecture sur pièce sont vidées.' ELSE N'' END;
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

