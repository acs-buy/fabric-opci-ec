-- ===================================================================== 1. LE REIMPORT D'UN CLASSEUR DE REFERENTIEL
-- ecran 5, lot 5, script 332 (61_DEPLOIEMENT/generer_e5_332_import_referentiel.py)
-- Objet n° 37 : les lignes du dernier classeur du referentiel (@lignes, tableau JSON, un objet par ligne de l'onglet, cles
-- de la ligne 2 et « _ligne »), jugees ligne a ligne aux regles des n° 11 (valeur) et 12 (ligne neuve), et aux refus des
-- n° 13 et 14 sur le code et l'ecart ; aucune suppression (n° 15). Tout ou rien : chaque valeur et chaque regle sont
-- jugees avant toute ecriture ; chaque ligne s'ecrit ensuite a son tour, et le 1er refus annule tout en nommant la ligne
-- du classeur. N'ecrit que les lignes dont une valeur change ; une ligne neuve recoit modifie_par = @par et modifie_le ;
-- par pose le temps des ecritures (objet n° 16) ; ref_ratio_vehicule exclue (action_propre).
CREATE   PROCEDURE dbo.pr_importer_referentiel
    @referentiel NVARCHAR (400)  = NULL,
    @lignes      NVARCHAR (MAX)  = NULL,
    @fichier     NVARCHAR (4000) = NULL,
    @par         NVARCHAR (400)  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    -- @@TRANCOUNT lu seul, avant toute lecture de table : sous IMPLICIT_TRANSACTIONS (connexion sans autocommit d'une
    -- Data function), la 1re lecture ouvrirait la transaction de l'appelant avant la mesure
    DECLARE @tc INT = @@TRANCOUNT;
    DECLARE @journal_avant INT = ISNULL((SELECT MAX(id) FROM dbo.journal_refus), 0),
            @proc VARCHAR (60) = 'pr_importer_referentiel', @e_num INT, @e_msg NVARCHAR (2048), @e_fr NVARCHAR (2000),
            @e_journal NVARCHAR (2000), @m NVARCHAR (2000), @message NVARCHAR (2000);
    -- le vide : les 29 caracteres de str.isspace(), compares au point de code (script 327)
    DECLARE @blancs NVARCHAR (29) = NCHAR(9) + NCHAR(10) + NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(28) + NCHAR(29) + NCHAR(30) + NCHAR(31) + NCHAR(32)
        + NCHAR(133) + NCHAR(160) + NCHAR(5760) + NCHAR(8192) + NCHAR(8193) + NCHAR(8194) + NCHAR(8195) + NCHAR(8196) + NCHAR(8197) + NCHAR(8198)
        + NCHAR(8199) + NCHAR(8200) + NCHAR(8201) + NCHAR(8202) + NCHAR(8232) + NCHAR(8233) + NCHAR(8239) + NCHAR(8287) + NCHAR(12288);
    DECLARE @t VARCHAR (120), @lib NVARCHAR (160), @mode VARCHAR (5), @actions TINYINT, @propre NVARCHAR (60),
            @designation VARCHAR (128), @oid INT, @dernier NVARCHAR (400), @dernier_le DATETIME2 (0), @f NVARCHAR (400),
            @nb_cles INT, @numerotee BIT, @pk1 SYSNAME, @pk2 SYSNAME, @r INT, @n INT, @c SYSNAME, @k SYSNAME, @x NVARCHAR (1500),
            @sql NVARCHAR (MAX), @col SYSNAME, @type NVARCHAR (60), @j_tl NVARCHAR (MAX), @set NVARCHAR (MAX),
            @cols NVARCHAR (MAX), @exprs NVARCHAR (MAX), @groupe_o NVARCHAR (MAX), @groupe_n NVARCHAR (MAX),
            @type_ref NVARCHAR (60), @type_norme NVARCHAR (60), @reset BIT, @neuve BIT, @rang_ecrit INT, @id INT,
            @modifiees INT, @ajoutees INT, @inchangees INT, @pfx NVARCHAR (800), @num INT, @i INT, @ex NVARCHAR (400),
            @cible SYSNAME, @col_cible SYSNAME;
    CREATE TABLE #col (
        colonne   SYSNAME COLLATE DATABASE_DEFAULT NOT NULL PRIMARY KEY,
        column_id INT NOT NULL,
        type_nom  SYSNAME COLLATE DATABASE_DEFAULT NOT NULL,
        type_sql  NVARCHAR (60) COLLATE DATABASE_DEFAULT NOT NULL,
        longueur  INT NULL,
        prec      INT NULL,
        echelle   INT NULL,
        nullable  BIT NOT NULL,
        identite  BIT NOT NULL,
        calculee  BIT NOT NULL,
        rang_cle  INT NULL,
        defaut    BIT NOT NULL,
        libelle   NVARCHAR (128) COLLATE DATABASE_DEFAULT NOT NULL,
        enum      BIT NOT NULL,
        fk_cible  SYSNAME COLLATE DATABASE_DEFAULT NULL,
        fk_col    SYSNAME COLLATE DATABASE_DEFAULT NULL,
        famille   VARCHAR (8) COLLATE DATABASE_DEFAULT NOT NULL);
    CREATE TABLE #lig (
        rang    INT NOT NULL PRIMARY KEY,
        ligne   INT NULL,
        vide    BIT NOT NULL,
        k1      NVARCHAR (400) COLLATE DATABASE_DEFAULT NULL,
        k2      NVARCHAR (400) COLLATE DATABASE_DEFAULT NULL,
        canon   NVARCHAR (850) COLLATE DATABASE_DEFAULT NULL,
        canon2  NVARCHAR (850) COLLATE DATABASE_DEFAULT NULL,
        existe  BIT NOT NULL,
        neuve   BIT NOT NULL,
        change  BIT NOT NULL,
        nom     NVARCHAR (400) COLLATE DATABASE_DEFAULT NULL,
        avant   NVARCHAR (400) COLLATE DATABASE_DEFAULT NULL,
        pfx AS CAST(N'Réimport refusé, ligne ' + CAST(ISNULL(ligne, rang) AS NVARCHAR (12))
                    + CASE WHEN ligne IS NULL THEN N' reçue' ELSE N' du classeur' END
                    + ISNULL(N' (« ' + NULLIF(nom, N'') + N' »)', N'') + N' : ' AS NVARCHAR (800)));
    CREATE TABLE #val (
        rang    INT NOT NULL,
        colonne SYSNAME COLLATE DATABASE_DEFAULT NOT NULL,
        brut    NVARCHAR (MAX) COLLATE DATABASE_DEFAULT NULL,
        jtype   TINYINT NOT NULL,
        vide    BIT NULL,
        texte   NVARCHAR (MAX) COLLATE DATABASE_DEFAULT NULL,
        aff     NVARCHAR (130) COLLATE DATABASE_DEFAULT NULL,
        valeur  NVARCHAR (MAX) COLLATE DATABASE_DEFAULT NULL,
        fait    BIT NULL,
        erreur  INT NULL,
        motif   NVARCHAR (1500) COLLATE DATABASE_DEFAULT NULL,
        change  BIT NULL,
        PRIMARY KEY (rang, colonne));
    CREATE TABLE #des (apres BIT NOT NULL, cle NVARCHAR (850) COLLATE DATABASE_DEFAULT NULL, ligne NVARCHAR (MAX) COLLATE DATABASE_DEFAULT NULL);
    BEGIN TRY
        -- 1. l'auteur, puis par pose avant la 1re ecriture (objet n° 16)
        IF ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM @par COLLATE Latin1_General_100_BIN2)), 0) = 0
            EXEC dbo.pr_e5_refuser 50900, N'Action refusée : l’auteur de l’action n’est pas transmis ; l’écran le transmet avec l’adresse de connexion de la personne qui clique.';
        SET @par = LTRIM(RTRIM(@par));
        EXEC sp_set_session_context N'par', @par;
        -- 2. le referentiel, puis les raisons de [Blocage reimporter le classeur], avant toute ecriture : TEXTE, PROPRE,
        --    DROIT (l'ordre des n° 11 a 15), puis aucun classeur depose
        IF ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM @referentiel COLLATE Latin1_General_100_BIN2)), 0) = 0
            EXEC dbo.pr_e5_refuser 50831, N'Choisissez le référentiel dans la liste « Référentiel ».';
        SET @referentiel = LEFT(LTRIM(RTRIM(@referentiel)), 200);
        EXEC dbo.pr_e5_lire_referentiel @referentiel, @t OUTPUT, @lib OUTPUT, @mode OUTPUT, @actions OUTPUT, @propre OUTPUT, @designation OUTPUT;
        IF @mode = 'TEXTE'
        BEGIN
            SET @m = N'Réimport refusé sur « ' + @lib + N' » : fixé par un texte, non modifiable.';
            EXEC dbo.pr_e5_refuser 50906, @m;
        END;
        IF @propre IS NOT NULL
        BEGIN
            SET @m = N'Réimport refusé sur « ' + @lib + N' » : seuil propre au véhicule, posé par « Enregistrer le seuil du véhicule ».';
            EXEC dbo.pr_e5_refuser 50907, @m;
        END;
        IF dbo.fn_peut_ecrire_referentiel(@t, @par) = 0
        BEGIN
            SET @m = N'Réimport refusé sur « ' + @lib + N' » : aucun droit de modification.';
            EXEC dbo.pr_e5_refuser 50908, @m;
        END;
        SELECT TOP (1) @dernier = cc.fichier, @dernier_le = cc.depose_le FROM dbo.classeur_cabinet cc
        WHERE cc.genre = 'REFERENTIEL' AND cc.referentiel = @t ORDER BY cc.depose_le DESC, cc.id DESC;
        IF @dernier IS NULL
        BEGIN
            SET @m = N'Réimport refusé sur « ' + @lib + N' » : aucun classeur déposé ; « Exporter le classeur » le dépose au dossier Référentiels du site du cabinet.';
            EXEC dbo.pr_e5_refuser 50909, @m;
        END;
        SET @f = CASE WHEN ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM @fichier COLLATE Latin1_General_100_BIN2)), 0) = 0 THEN @dernier ELSE LEFT(LTRIM(RTRIM(@fichier)), 400) END;
        IF @f <> @dernier
        BEGIN
            SET @m = N'Réimport refusé : le classeur relu « ' + @f + N' » n’est pas le dernier classeur déposé du référentiel « ' + @lib
                   + N' », « ' + @dernier + N' », déposé le ' + CONVERT(NVARCHAR (10), @dernier_le, 103) + N'.';
            EXEC dbo.pr_e5_refuser 50909, @m;
        END;
        -- 3. les colonnes du referentiel, lues au catalogue a l'execution : un referentiel qui s'ajoute se reimporte sans
        --    regeneration ; famille : CLE (code), HORO (horodatage, sans effet), CALC et HORS (sans effet), ECART, PARAM
        --    (parametre autre que la valeur), FIGEE (non modifiable a la liste, intitule et citation d'une reference), LIBRE
        SET @oid = OBJECT_ID(N'dbo.' + QUOTENAME(@t));
        INSERT INTO #col (colonne, column_id, type_nom, type_sql, longueur, prec, echelle, nullable, identite, calculee, rang_cle,
                          defaut, libelle, enum, fk_cible, fk_col, famille)
        SELECT x.colonne, x.column_id, x.type_nom, x.type_sql, x.longueur, x.prec, x.echelle, x.nullable, x.identite, x.calculee,
               x.rang_cle, x.defaut, x.libelle, x.enum, x.fk_cible, x.fk_col,
               CAST(CASE WHEN x.calculee = 1 THEN 'CALC'
                    WHEN x.rang_cle IS NOT NULL THEN 'CLE'
                    WHEN x.colonne IN (N'modifie_par', N'modifie_le', N'pose_par', N'pose_le') THEN 'HORO'
                    WHEN x.type_nom NOT IN (N'tinyint', N'smallint', N'int', N'bigint', N'decimal', N'numeric', N'bit', N'date',
                                            N'varchar', N'char', N'nvarchar', N'nchar') THEN 'HORS'
                    WHEN x.colonne IN (N'ecartee_le', N'ecartee_par', N'motif_ecart') THEN 'ECART'
                    WHEN @t = 'ref_parametre' AND x.colonne <> N'valeur' THEN 'PARAM'
                    WHEN (@t = 'ref_reference' AND x.colonne IN (N'intitule', N'citation')) OR x.modifiable = 0 THEN 'FIGEE'
                    ELSE 'LIBRE' END AS VARCHAR (8)) AS famille
        FROM (SELECT c.name COLLATE DATABASE_DEFAULT AS colonne, c.column_id, TYPE_NAME(c.user_type_id) COLLATE DATABASE_DEFAULT AS type_nom,
                     dbo.fn_e5_type_colonne(@t, c.name) AS type_sql,
                     CASE WHEN c.max_length = -1 THEN -1 WHEN TYPE_NAME(c.user_type_id) IN (N'nvarchar', N'nchar') THEN c.max_length / 2
                          ELSE c.max_length END AS longueur,
                     CAST(c.precision AS INT) AS prec, CAST(c.scale AS INT) AS echelle, c.is_nullable AS nullable,
                     c.is_identity AS identite, c.is_computed AS calculee,
                     (SELECT ic.key_ordinal FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
                      WHERE i.object_id = @oid AND i.is_primary_key = 1 AND ic.column_id = c.column_id) AS rang_cle,
                     CAST(CASE WHEN c.default_object_id <> 0 THEN 1 ELSE 0 END AS BIT) AS defaut,
                     dbo.fn_e5_libelle_colonne(@t, c.name) AS libelle,
                     (SELECT TOP (1) vc.modifiable FROM dbo.v_ecran_referentiel_colonnes vc
                      WHERE vc.referentiel = @t AND vc.colonne = c.name COLLATE DATABASE_DEFAULT) AS modifiable,
                     CAST(CASE WHEN EXISTS (SELECT 1 FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = @t AND lv.colonne = c.name COLLATE DATABASE_DEFAULT)
                               THEN 1 ELSE 0 END AS BIT) AS enum,
                     (SELECT TOP (1) OBJECT_NAME(fk.referenced_object_id) COLLATE DATABASE_DEFAULT FROM sys.foreign_keys fk
                      JOIN sys.foreign_key_columns fc ON fc.constraint_object_id = fk.object_id
                      WHERE fk.parent_object_id = @oid AND fc.parent_column_id = c.column_id
                        AND NOT EXISTS (SELECT 1 FROM sys.foreign_key_columns f2 WHERE f2.constraint_object_id = fk.object_id AND f2.constraint_column_id > 1)) AS fk_cible,
                     (SELECT TOP (1) rc.name COLLATE DATABASE_DEFAULT FROM sys.foreign_keys fk
                      JOIN sys.foreign_key_columns fc ON fc.constraint_object_id = fk.object_id
                      JOIN sys.columns rc ON rc.object_id = fc.referenced_object_id AND rc.column_id = fc.referenced_column_id
                      WHERE fk.parent_object_id = @oid AND fc.parent_column_id = c.column_id
                        AND NOT EXISTS (SELECT 1 FROM sys.foreign_key_columns f2 WHERE f2.constraint_object_id = fk.object_id AND f2.constraint_column_id > 1)) AS fk_col
              FROM sys.columns c WHERE c.object_id = @oid) x;
        SELECT @nb_cles = COUNT(*), @numerotee = MAX(CAST(c.identite AS INT)) FROM #col c WHERE c.rang_cle IS NOT NULL;
        IF ISNULL(@nb_cles, 0) NOT IN (1, 2)
        BEGIN
            SET @m = N'Réimport refusé sur « ' + @lib + N' » : le code de ce référentiel ne tient pas en 1 ou 2 parties, que le classeur sait lire.';
            EXEC dbo.pr_e5_refuser 50911, @m;
        END;
        -- 343 (30/10/2026) : ELSE N'' dans le MAX, repris par NULLIF : aucun NULL dans l'agregat, donc aucun avertissement 8153, que
        -- le pilote lirait a la place du refus. Genere par 61_DEPLOIEMENT/generer_e5_343_correctif_avertissement_8153.py.
        SELECT @pk1 = NULLIF(MAX(CASE WHEN c.rang_cle = 1 THEN c.colonne ELSE N'' END), N''),
               @pk2 = NULLIF(MAX(CASE WHEN c.rang_cle = 2 THEN c.colonne ELSE N'' END), N''),
               @type_ref = NULLIF(MAX(CASE WHEN c.colonne = N'reference' THEN c.type_sql ELSE N'' END), N''),
               @type_norme = NULLIF(MAX(CASE WHEN c.colonne = N'norme' THEN c.type_sql ELSE N'' END), N'')
        FROM #col c;
        -- 4. le contenu recu : un tableau JSON d'objets, une colonne une fois par ligne
        IF ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM @lignes COLLATE Latin1_General_100_BIN2)), 0) = 0
        BEGIN
            SET @m = N'Réimport refusé : le contenu du classeur du référentiel « ' + @lib + N' » n’est pas parvenu.';
            EXEC dbo.pr_e5_refuser 50910, @m;
        END;
        IF ISJSON(@lignes) = 0 OR LEFT(LTRIM(@lignes), 1) <> N'['
            EXEC dbo.pr_e5_refuser 50910, N'Réimport refusé : le contenu reçu n’est pas un tableau de lignes lisible.';
        SET @r = NULL;
        SELECT TOP (1) @r = CAST(a.[key] AS INT) + 1 FROM OPENJSON(@lignes) a WHERE a.[type] <> 5 ORDER BY CAST(a.[key] AS INT);
        IF @r IS NOT NULL
        BEGIN
            SET @m = N'Réimport refusé : l’élément ' + CAST(@r AS NVARCHAR (12)) + N' du contenu reçu n’est pas une ligne du classeur.';
            EXEC dbo.pr_e5_refuser 50910, @m;
        END;
        INSERT INTO #lig (rang, ligne, vide, existe, neuve, change)
        SELECT CAST(a.[key] AS INT) + 1, TRY_CAST(JSON_VALUE(a.value, N'$."_ligne"') AS INT), 0, 0, 0, 0 FROM OPENJSON(@lignes) a;
        SET @r = NULL;
        SELECT TOP (1) @r = x.rang, @c = x.colonne
        FROM (SELECT CAST(a.[key] AS INT) + 1 AS rang, c.colonne FROM OPENJSON(@lignes) a CROSS APPLY OPENJSON(a.value) j
              JOIN #col c ON c.colonne = j.[key] COLLATE DATABASE_DEFAULT
              GROUP BY CAST(a.[key] AS INT), c.colonne HAVING COUNT(*) > 1) x
        ORDER BY x.rang;
        IF @r IS NOT NULL
        BEGIN
            SELECT @m = l.pfx + N'la colonne « ' + (SELECT c.libelle FROM #col c WHERE c.colonne = @c) + N' » y figure 2 fois. Aucune ligne n’est écrite.'
            FROM #lig l WHERE l.rang = @r;
            EXEC dbo.pr_e5_refuser 50910, @m;
        END;
        INSERT INTO #val (rang, colonne, brut, jtype)
        SELECT CAST(a.[key] AS INT) + 1, c.colonne, j.[value], j.[type]
        FROM OPENJSON(@lignes) a CROSS APPLY OPENJSON(a.value) j JOIN #col c ON c.colonne = j.[key] COLLATE DATABASE_DEFAULT
        WHERE c.famille NOT IN ('CALC', 'HORO', 'HORS');
        -- une ligne de l'onglet sans valeur s'ignore
        UPDATE v SET vide = CASE WHEN ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM v.brut COLLATE Latin1_General_100_BIN2)), 0) = 0 THEN 1 ELSE 0 END FROM #val v;
        UPDATE l SET vide = CASE WHEN EXISTS (SELECT 1 FROM #val v WHERE v.rang = l.rang AND v.vide = 0) THEN 0 ELSE 1 END FROM #lig l;
        DELETE v FROM #val v JOIN #lig l ON l.rang = v.rang AND l.vide = 1;
        DELETE FROM #lig WHERE vide = 1;
        IF NOT EXISTS (SELECT 1 FROM #lig)
        BEGIN
            SET @m = N'Réimport refusé : le classeur ne porte aucune ligne du référentiel « ' + @lib + N' ».';
            EXEC dbo.pr_e5_refuser 50910, @m;
        END;
        -- la colonne du code, presente a chaque ligne, meme vide (une ligne neuve d'un referentiel numerote)
        SET @r = NULL;
        SELECT TOP (1) @r = l.rang, @c = c.colonne FROM #lig l JOIN #col c ON c.rang_cle IS NOT NULL
        WHERE NOT EXISTS (SELECT 1 FROM #val v WHERE v.rang = l.rang AND v.colonne = c.colonne)
        ORDER BY l.rang, c.rang_cle;
        IF @r IS NOT NULL
        BEGIN
            SELECT @m = l.pfx + N'la colonne « ' + (SELECT c.libelle FROM #col c WHERE c.colonne = @c) + N' », qui désigne la ligne, manque au classeur. Aucune ligne n’est écrite.'
            FROM #lig l WHERE l.rang = @r;
            EXEC dbo.pr_e5_refuser 50910, @m;
        END;
        -- 5. les valeurs, a la forme de leur colonne (regles de l'objet n° 11) ; une erreur sur le code se refuse en 50911
        UPDATE v SET texte = CASE WHEN v.vide = 1 THEN NULL
                                  WHEN v.jtype = 3 THEN CASE WHEN v.brut = N'true' THEN N'1' ELSE N'0' END
                                  ELSE LTRIM(RTRIM(v.brut)) END
        FROM #val v;
        UPDATE #val SET aff = CASE WHEN LEN(texte) > 120 THEN LEFT(texte, 119) + N'…' ELSE texte END;
        UPDATE v SET erreur = CASE WHEN c.rang_cle IS NULL THEN 50912 ELSE 50911 END,
                     motif = N'la colonne « ' + c.libelle + N' » ne porte pas une valeur lisible.'
        FROM #val v JOIN #col c ON c.colonne = v.colonne WHERE v.jtype IN (4, 5);
        -- les valeurs d'une enumeration : libelle ou code (ref_libelle_valeur, objet n° 8)
        UPDATE v SET texte = ISNULL(x.code, v.texte),
                     erreur = CASE WHEN x.code IS NULL THEN CASE WHEN c.rang_cle IS NULL THEN 50913 ELSE 50911 END END,
                     motif = CASE WHEN x.code IS NULL THEN N'la colonne « ' + c.libelle + N' » vaut « ' + v.aff + N' », qui n’est pas une valeur admise ; valeurs admises : '
                                  + ISNULL((SELECT STRING_AGG(CAST(N'« ' + lv.libelle + N' »' AS NVARCHAR (MAX)), N', ') WITHIN GROUP (ORDER BY lv.libelle)
                                            FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = @t AND lv.colonne = v.colonne), N'') + N'.' END
        FROM #val v JOIN #col c ON c.colonne = v.colonne
        OUTER APPLY (SELECT TOP (1) lv.valeur AS code FROM dbo.ref_libelle_valeur lv
                     WHERE lv.table_nom = @t AND lv.colonne = v.colonne AND (lv.libelle = v.texte OR lv.valeur = v.texte)
                     ORDER BY CASE WHEN lv.libelle = v.texte THEN 0 ELSE 1 END) x
        WHERE c.enum = 1 AND v.vide = 0 AND v.erreur IS NULL;
        -- une reference normative : « norme reference » ou identifiant
        SET @ex = (SELECT TOP (1) r.norme + N' ' + r.reference FROM dbo.ref_reference r ORDER BY r.id);
        UPDATE v SET valeur = CAST(x.id AS NVARCHAR (12)), fait = 1,
                     erreur = CASE WHEN x.id IS NULL THEN CASE WHEN c.rang_cle IS NULL THEN 50914 ELSE 50911 END END,
                     motif = CASE WHEN x.id IS NULL THEN N'la colonne « ' + c.libelle + N' » vaut « ' + v.aff
                                  + N' », qui n’est pas une référence normative ; elle se saisit « norme référence », comme « ' + ISNULL(@ex, N'') + N' ».' END
        FROM #val v JOIN #col c ON c.colonne = v.colonne
        OUTER APPLY (SELECT TOP (1) r.id FROM dbo.ref_reference r
                     WHERE r.norme + N' ' + r.reference = v.texte OR (v.texte NOT LIKE N'%[^0-9]%' AND LEN(v.texte) <= 9 AND r.id = TRY_CAST(v.texte AS INT))
                     ORDER BY CASE WHEN r.norme + N' ' + r.reference = v.texte THEN 0 ELSE 1 END) x
        WHERE c.fk_cible = N'ref_reference' AND c.fk_col = N'id' AND v.vide = 0 AND v.erreur IS NULL;
        -- une question de reference : sa reference ou son identifiant
        SET @ex = (SELECT TOP (1) q.reference FROM dbo.ref_question q ORDER BY q.id);
        UPDATE v SET valeur = CAST(x.id AS NVARCHAR (12)), fait = 1,
                     erreur = CASE WHEN x.id IS NULL THEN CASE WHEN c.rang_cle IS NULL THEN 50914 ELSE 50911 END END,
                     motif = CASE WHEN x.id IS NULL THEN N'la colonne « ' + c.libelle + N' » vaut « ' + v.aff
                                  + N' », qui n’est pas une question de référence ; elle se saisit par la référence de la question, comme « ' + ISNULL(@ex, N'') + N' ».' END
        FROM #val v JOIN #col c ON c.colonne = v.colonne
        OUTER APPLY (SELECT TOP (1) q.id FROM dbo.ref_question q
                     WHERE q.reference = v.texte OR (v.texte NOT LIKE N'%[^0-9]%' AND LEN(v.texte) <= 9 AND q.id = TRY_CAST(v.texte AS INT))
                     ORDER BY CASE WHEN q.reference = v.texte THEN 0 ELSE 1 END) x
        WHERE c.fk_cible = N'ref_question' AND c.fk_col = N'id' AND v.vide = 0 AND v.erreur IS NULL;
        -- un sujet des questions sur la tenue : son libelle ou son code (B14)
        SET @ex = (SELECT TOP (1) s.libelle FROM dbo.ref_sujet_tenue s ORDER BY s.code);
        UPDATE v SET valeur = x.code, fait = 1,
                     erreur = CASE WHEN x.code IS NULL THEN CASE WHEN c.rang_cle IS NULL THEN 50914 ELSE 50911 END END,
                     motif = CASE WHEN x.code IS NULL THEN N'la colonne « ' + c.libelle + N' » vaut « ' + v.aff + N' », qui n’est pas une ligne du référentiel « '
                                  + dbo.fn_e5_libelle_referentiel('ref_sujet_tenue') + N' » ; elle se saisit par son libellé, comme « ' + ISNULL(@ex, N'') + N' ».' END
        FROM #val v JOIN #col c ON c.colonne = v.colonne
        OUTER APPLY (SELECT TOP (1) s.code FROM dbo.ref_sujet_tenue s WHERE s.libelle = v.texte OR s.code = v.texte
                     ORDER BY CASE WHEN s.libelle = v.texte THEN 0 ELSE 1 END) x
        WHERE c.fk_cible = N'ref_sujet_tenue' AND c.fk_col = N'code' AND v.vide = 0 AND v.erreur IS NULL;
        -- les nombres : y.b, le nombre lu borne avant tout arrondi ; a 9999999999999999999999999999,5 et au-dela en valeur
        -- absolue, ROUND deborderait DECIMAL (38, 10) (erreur 8115, en anglais) : y.b est vide et le nombre se refuse au
        -- texte de sa colonne, ligne et colonne nommees (50912, 50911 pour le code)
        -- les nombres entiers
        UPDATE v SET fait = 1,
                     valeur = CASE WHEN y.b IS NOT NULL AND y.b = ROUND(y.b, 0)
                                    AND y.b >= CASE c.type_nom WHEN N'tinyint' THEN 0 WHEN N'smallint' THEN -32768 WHEN N'int' THEN -2147483648 ELSE -9223372036854775808 END
                                    AND y.b <= CASE c.type_nom WHEN N'tinyint' THEN 255 WHEN N'smallint' THEN 32767 WHEN N'int' THEN 2147483647 ELSE 9223372036854775807 END
                                   THEN CAST(CAST(y.b AS BIGINT) AS NVARCHAR (20)) END
        FROM #val v JOIN #col c ON c.colonne = v.colonne
        CROSS APPLY (SELECT CASE WHEN LEN(v.texte) > 60 THEN NULL
                                 WHEN v.jtype = 2 AND v.texte LIKE N'%[eE]%' THEN TRY_CONVERT(DECIMAL (38, 10), TRY_CONVERT(FLOAT, v.texte))
                                 ELSE dbo.fn_e5_nombre(v.texte) END AS n) x
        CROSS APPLY (SELECT CASE WHEN ABS(x.n) < 9999999999999999999999999999.5 THEN x.n END AS b) y
        WHERE c.type_nom IN (N'tinyint', N'smallint', N'int', N'bigint') AND v.vide = 0 AND v.erreur IS NULL AND v.fait IS NULL;
        UPDATE v SET erreur = CASE WHEN c.rang_cle IS NULL THEN 50912 ELSE 50911 END,
                     motif = N'la colonne « ' + c.libelle + N' » vaut « ' + v.aff + N' », qui n’est pas un nombre entier qu’elle admet.'
        FROM #val v JOIN #col c ON c.colonne = v.colonne
        WHERE c.type_nom IN (N'tinyint', N'smallint', N'int', N'bigint') AND v.vide = 0 AND v.erreur IS NULL AND v.fait = 1 AND v.valeur IS NULL;
        -- les nombres decimaux
        UPDATE v SET fait = 1,
                     valeur = CASE WHEN y.b IS NOT NULL AND y.b = ROUND(y.b, c.echelle)
                                    AND CASE WHEN c.prec - c.echelle >= 28 THEN 1
                                             WHEN ABS(y.b) < POWER(CAST(10 AS DECIMAL (38, 0)), c.prec - c.echelle) THEN 1 ELSE 0 END = 1
                                   THEN CAST(y.b AS NVARCHAR (60)) END,
                     erreur = CASE WHEN y.b IS NULL OR y.b <> ROUND(y.b, c.echelle)
                                        OR CASE WHEN c.prec - c.echelle >= 28 THEN 1
                                                WHEN ABS(y.b) < POWER(CAST(10 AS DECIMAL (38, 0)), c.prec - c.echelle) THEN 1 ELSE 0 END = 0
                                   THEN CASE WHEN c.rang_cle IS NULL THEN 50912 ELSE 50911 END END,
                     motif = CASE WHEN x.n IS NULL THEN N'la colonne « ' + c.libelle + N' » vaut « ' + v.aff + N' », qui n’est pas un nombre.'
                                  ELSE N'la colonne « ' + c.libelle + N' » vaut « ' + v.aff + N' », qui dépasse ses ' + CAST(c.prec - c.echelle AS NVARCHAR (4))
                                       + N' chiffres avant la virgule et ' + CAST(c.echelle AS NVARCHAR (4)) + N' après.' END
        FROM #val v JOIN #col c ON c.colonne = v.colonne
        CROSS APPLY (SELECT CASE WHEN LEN(v.texte) > 60 THEN NULL
                                 WHEN v.jtype = 2 AND v.texte LIKE N'%[eE]%' THEN TRY_CONVERT(DECIMAL (38, 10), TRY_CONVERT(FLOAT, v.texte))
                                 ELSE dbo.fn_e5_nombre(v.texte) END AS n) x
        CROSS APPLY (SELECT CASE WHEN ABS(x.n) < 9999999999999999999999999999.5 THEN x.n END AS b) y
        WHERE c.type_nom IN (N'decimal', N'numeric') AND v.vide = 0 AND v.erreur IS NULL AND v.fait IS NULL;
        UPDATE v SET motif = NULL FROM #val v WHERE v.erreur IS NULL AND v.fait = 1 AND v.valeur IS NOT NULL AND v.motif IS NOT NULL;
        -- oui ou non
        UPDATE v SET fait = 1,
                     valeur = CASE WHEN LOWER(v.texte) IN (N'1', N'oui', N'vrai', N'true') THEN N'1'
                                   WHEN LOWER(v.texte) IN (N'0', N'non', N'faux', N'false') THEN N'0' END
        FROM #val v JOIN #col c ON c.colonne = v.colonne
        WHERE c.type_nom = N'bit' AND v.vide = 0 AND v.erreur IS NULL AND v.fait IS NULL;
        UPDATE v SET erreur = CASE WHEN c.rang_cle IS NULL THEN 50912 ELSE 50911 END,
                     motif = N'la colonne « ' + c.libelle + N' » vaut « ' + v.aff + N' », qui n’est pas une valeur admise ; valeurs admises : « oui », « non ».'
        FROM #val v JOIN #col c ON c.colonne = v.colonne
        WHERE c.type_nom = N'bit' AND v.vide = 0 AND v.erreur IS NULL AND v.fait = 1 AND v.valeur IS NULL;
        -- les dates : jj/mm/aaaa (fn_e5_date), ou aaaa-mm-jj, heure 00:00:00 admise
        UPDATE v SET fait = 1, valeur = CONVERT(NVARCHAR (10), x.d, 23)
        FROM #val v JOIN #col c ON c.colonne = v.colonne
        CROSS APPLY (SELECT CASE WHEN LEN(v.texte) <= 40 AND dbo.fn_e5_date(v.texte) IS NOT NULL THEN dbo.fn_e5_date(v.texte)
                                 WHEN v.texte LIKE N'[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' THEN TRY_CONVERT(DATE, v.texte, 23)
                                 WHEN LEN(v.texte) <= 40 AND v.texte LIKE N'[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][ T]00:00:00%'
                                      AND SUBSTRING(v.texte, 20, 40) NOT LIKE N'%[^.0]%' THEN TRY_CONVERT(DATE, LEFT(v.texte, 10), 23) END AS d) x
        WHERE c.type_nom = N'date' AND v.vide = 0 AND v.erreur IS NULL AND v.fait IS NULL;
        UPDATE v SET erreur = CASE WHEN c.rang_cle IS NULL THEN 50912 ELSE 50911 END,
                     motif = N'la colonne « ' + c.libelle + N' » vaut « ' + v.aff + N' », qui n’est pas une date jj/mm/aaaa.'
        FROM #val v JOIN #col c ON c.colonne = v.colonne
        WHERE c.type_nom = N'date' AND v.vide = 0 AND v.erreur IS NULL AND v.fait = 1 AND v.valeur IS NULL;
        -- les textes : longueur de la colonne, caracteres qu'une colonne varchar admet
        UPDATE v SET fait = 1,
                     valeur = CASE WHEN (c.longueur = -1 OR LEN(v.texte) <= c.longueur)
                                    AND (c.type_nom NOT IN (N'varchar', N'char')
                                         OR CAST(CAST(v.texte AS VARCHAR (MAX)) AS NVARCHAR (MAX)) COLLATE Latin1_General_BIN2 = v.texte COLLATE Latin1_General_BIN2)
                                   THEN v.texte END,
                     erreur = CASE WHEN c.longueur <> -1 AND LEN(v.texte) > c.longueur THEN CASE WHEN c.rang_cle IS NULL THEN 50912 ELSE 50911 END
                                   WHEN c.type_nom IN (N'varchar', N'char')
                                        AND CAST(CAST(v.texte AS VARCHAR (MAX)) AS NVARCHAR (MAX)) COLLATE Latin1_General_BIN2 <> v.texte COLLATE Latin1_General_BIN2
                                   THEN CASE WHEN c.rang_cle IS NULL THEN 50912 ELSE 50911 END END,
                     motif = CASE WHEN c.longueur <> -1 AND LEN(v.texte) > c.longueur
                                  THEN N'la colonne « ' + c.libelle + N' » porte ' + CAST(LEN(v.texte) AS NVARCHAR (12)) + N' caractères, pour ' + CAST(c.longueur AS NVARCHAR (12)) + N' au plus.'
                                  ELSE N'la colonne « ' + c.libelle + N' » porte un caractère qu’elle n’admet pas.' END
        FROM #val v JOIN #col c ON c.colonne = v.colonne
        WHERE c.type_nom IN (N'varchar', N'char', N'nvarchar', N'nchar') AND v.vide = 0 AND v.erreur IS NULL AND v.fait IS NULL;
        UPDATE v SET motif = NULL FROM #val v WHERE v.erreur IS NULL AND v.motif IS NOT NULL;
        -- la valeur d'un seuil des parametres du cabinet, entiere : ramenee a sa forme (« 007 » vaut 7), comme au n° 11
        UPDATE v SET valeur = ISNULL(CAST(TRY_CAST(v.valeur AS INT) AS NVARCHAR (12)), v.valeur)
        FROM #val v WHERE @t = 'ref_parametre' AND v.colonne = N'valeur' AND v.erreur IS NULL AND v.valeur NOT LIKE N'%[^0-9]%' AND LEN(v.valeur) BETWEEN 1 AND 9;
        -- 6. le code de chaque ligne, puis la 1re erreur de valeur, dans l'ordre du classeur
        UPDATE l SET k1 = LEFT(v1.valeur, 400), k2 = LEFT(v2.valeur, 400),
                     nom = LEFT(v1.aff + ISNULL(N' ' + NCHAR (183) + N' ' + v2.aff, N''), 400)
        FROM #lig l LEFT JOIN #val v1 ON v1.rang = l.rang AND v1.colonne = @pk1 LEFT JOIN #val v2 ON v2.rang = l.rang AND v2.colonne = @pk2;
        SET @r = NULL;
        SELECT TOP (1) @r = v.rang, @num = v.erreur, @x = v.motif FROM #val v JOIN #col c ON c.colonne = v.colonne
        WHERE v.erreur IS NOT NULL ORDER BY v.rang, c.column_id;
        IF @r IS NOT NULL
        BEGIN
            SELECT @m = l.pfx + @x + N' Aucune ligne n’est écrite.' FROM #lig l WHERE l.rang = @r;
            EXEC dbo.pr_e5_refuser @num, @m;
        END;
        -- un code vide (referentiel a code saisi) ; une ligne neuve d'un referentiel numerote laisse vide son identifiant
        IF @numerotee = 0
        BEGIN
            SET @r = NULL;
            SELECT TOP (1) @r = l.rang, @c = c.colonne FROM #lig l JOIN #col c ON c.rang_cle IS NOT NULL
            WHERE NOT EXISTS (SELECT 1 FROM #val v WHERE v.rang = l.rang AND v.colonne = c.colonne AND v.valeur IS NOT NULL)
            ORDER BY l.rang, c.rang_cle;
            IF @r IS NOT NULL
            BEGIN
                SELECT @m = l.pfx + N'la colonne « ' + (SELECT c.libelle FROM #col c WHERE c.colonne = @c)
                          + N' » est vide : chaque ligne du classeur porte son code, et une ligne neuve le code qu’elle prend. Aucune ligne n’est écrite.'
                FROM #lig l WHERE l.rang = @r;
                EXEC dbo.pr_e5_refuser 50911, @m;
            END;
        END;
        -- 7. les lignes connues : le code compare a la table, a la forme de ses colonnes
        SELECT @j_tl = STRING_AGG(CAST(N't.' + QUOTENAME(c.colonne) + N' = CAST(l.k' + CAST(c.rang_cle AS NVARCHAR (1)) + N' AS ' + c.type_sql + N')' AS NVARCHAR (MAX)), N' AND ')
                      WITHIN GROUP (ORDER BY c.rang_cle)
        FROM #col c WHERE c.rang_cle IS NOT NULL;
        SET @sql = N'UPDATE l SET existe = CASE WHEN EXISTS (SELECT 1 FROM dbo.' + QUOTENAME(@t) + N' AS t WHERE ' + @j_tl
                 + N') THEN 1 ELSE 0 END FROM #lig l WHERE l.k1 IS NOT NULL;';
        EXEC sp_executesql @sql;
        IF @numerotee = 1
        BEGIN
            SET @r = NULL;
            SELECT TOP (1) @r = l.rang, @x = l.k1 FROM #lig l WHERE l.k1 IS NOT NULL AND l.existe = 0 ORDER BY l.rang;
            IF @r IS NOT NULL
            BEGIN
                SELECT @m = l.pfx + N'la ligne « ' + @x + N' » n’est pas au référentiel « ' + @lib + N' » ; une ligne neuve d’un référentiel numéroté laisse vide la colonne « '
                          + (SELECT c.libelle FROM #col c WHERE c.colonne = @pk1) + N' ». Aucune ligne n’est écrite.'
                FROM #lig l WHERE l.rang = @r;
                EXEC dbo.pr_e5_refuser 50911, @m;
            END;
        END;
        UPDATE #lig SET neuve = CASE WHEN existe = 1 THEN 0 ELSE 1 END;
        SET @r = NULL;
        SELECT TOP (1) @r = b.rang, @n = ISNULL(a.ligne, a.rang)
        FROM #lig a JOIN #lig b ON b.rang > a.rang
        WHERE a.k1 IS NOT NULL AND EXISTS (SELECT a.k1, a.k2 INTERSECT SELECT b.k1, b.k2)
        ORDER BY b.rang, a.rang;
        IF @r IS NOT NULL
        BEGIN
            SELECT @m = l.pfx + N'la ligne figure aussi à la ligne ' + CAST(@n AS NVARCHAR (12)) + N' du classeur. Aucune ligne n’est écrite.' FROM #lig l WHERE l.rang = @r;
            EXEC dbo.pr_e5_refuser 50911, @m;
        END;
        -- le code a la forme de la liste (v_ecran_referentiel_lignes : identifiant d'une question, « norme reference »
        -- d'une reference) et la designation de chaque ligne connue, qui la nomme dans les refus
        UPDATE l SET canon = l.k1 + ISNULL(N' ' + NCHAR (183) + N' ' + l.k2, N''),
                     canon2 = ISNULL(h1.h, l.k1) + ISNULL(N' ' + NCHAR (183) + N' ' + ISNULL(h2.h, l.k2), N'')
        FROM #lig l
        OUTER APPLY (SELECT TOP (1) r.norme + N' ' + r.reference AS h FROM dbo.ref_reference r JOIN #col c ON c.colonne = @pk1
                     WHERE c.fk_cible = N'ref_reference' AND c.fk_col = N'id' AND c.identite = 0 AND r.id = TRY_CAST(l.k1 AS INT)) h1
        OUTER APPLY (SELECT TOP (1) r.norme + N' ' + r.reference AS h FROM dbo.ref_reference r JOIN #col c ON c.colonne = @pk2
                     WHERE c.fk_cible = N'ref_reference' AND c.fk_col = N'id' AND c.identite = 0 AND r.id = TRY_CAST(l.k2 AS INT)) h2
        WHERE l.k1 IS NOT NULL;
        INSERT INTO #des (apres, cle, ligne) SELECT 0, d.cle, d.ligne FROM dbo.v_ecran_referentiel_lignes d WHERE d.referentiel = @t OPTION (RECOMPILE);
        UPDATE l SET avant = LEFT(d.ligne, 400), nom = LEFT(ISNULL(d.ligne, l.canon2), 400)
        FROM #lig l OUTER APPLY (SELECT TOP (1) x.ligne FROM #des x WHERE x.apres = 0 AND x.cle IN (l.canon, l.canon2)) d
        WHERE l.existe = 1;
        UPDATE l SET nom = LEFT(COALESCE(l.canon2, (SELECT v.aff FROM #val v WHERE v.rang = l.rang AND v.colonne = @designation)), 400)
        FROM #lig l WHERE l.neuve = 1;
        -- 8. les valeurs changees des lignes connues
        DECLARE c_col CURSOR LOCAL FAST_FORWARD FOR
            SELECT c.colonne, c.type_sql
            FROM #col c
            WHERE c.famille IN ('LIBRE', 'FIGEE', 'ECART', 'PARAM')
              AND EXISTS (SELECT 1 FROM #val v JOIN #lig l ON l.rang = v.rang AND l.existe = 1 WHERE v.colonne = c.colonne)
            ORDER BY c.column_id;
        OPEN c_col;
        FETCH NEXT FROM c_col INTO @col, @type;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @sql = N'UPDATE v SET change = CASE WHEN EXISTS (SELECT t.' + QUOTENAME(@col) + N' INTERSECT SELECT CAST(v.valeur AS ' + @type
                     + N')) THEN 0 ELSE 1 END FROM #val v JOIN #lig l ON l.rang = v.rang AND l.existe = 1 JOIN dbo.' + QUOTENAME(@t) + N' AS t ON '
                     + @j_tl + N' WHERE v.colonne = @c;';
            EXEC sp_executesql @sql, N'@c SYSNAME', @c = @col;
            FETCH NEXT FROM c_col INTO @col, @type;
        END;
        CLOSE c_col;
        DEALLOCATE c_col;
        UPDATE l SET change = CASE WHEN EXISTS (SELECT 1 FROM #val v WHERE v.rang = l.rang AND v.change = 1) THEN 1 ELSE 0 END
        FROM #lig l WHERE l.existe = 1;
        -- 8 bis. les autres cles etrangeres d'une colonne, hors reference, question et sujet (lus a l'etape 5) : chaque valeur
        --    d'une ligne neuve ou changee designe une ligne de la table visee, jugee par colonne en une instruction avant les
        --    regles de l'etape 9, comme pr_e5_controler_reference (50851) au n° 11 ; refus 50914 (50911 pour une partie du
        --    code), la ligne, la colonne et la valeur nommees ; la contrainte (547) reste le filet de l'ecriture
        DECLARE c_fk CURSOR LOCAL FAST_FORWARD FOR
            SELECT c.colonne, c.fk_cible, c.fk_col, CAST(CASE WHEN c.rang_cle IS NULL THEN 50914 ELSE 50911 END AS INT)
            FROM #col c
            WHERE c.fk_cible IS NOT NULL AND OBJECT_ID(N'dbo.' + QUOTENAME(c.fk_cible), N'U') IS NOT NULL
              AND NOT (c.fk_cible IN (N'ref_reference', N'ref_question') AND c.fk_col = N'id')
              AND NOT (c.fk_cible = N'ref_sujet_tenue' AND c.fk_col = N'code')
              AND EXISTS (SELECT 1 FROM #val v JOIN #lig l ON l.rang = v.rang
                          WHERE v.colonne = c.colonne AND v.valeur IS NOT NULL AND (l.neuve = 1 OR v.change = 1))
            ORDER BY c.column_id;
        OPEN c_fk;
        FETCH NEXT FROM c_fk INTO @col, @cible, @col_cible, @num;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @sql = N'UPDATE v SET erreur = @num FROM #val v JOIN #lig l ON l.rang = v.rang WHERE v.colonne = @c AND v.valeur IS NOT NULL'
                     + N' AND (l.neuve = 1 OR v.change = 1) AND NOT EXISTS (SELECT 1 FROM dbo.' + QUOTENAME(@cible) + N' AS x WHERE x.'
                     + QUOTENAME(@col_cible) + N' = TRY_CAST(v.valeur AS ' + dbo.fn_e5_type_colonne(@cible, @col_cible) + N'))'
                     + CASE WHEN @cible = @t AND @col_cible = @pk1 AND @nb_cles = 1
                            THEN N' AND NOT EXISTS (SELECT 1 FROM #lig l2 WHERE l2.neuve = 1 AND l2.rang < l.rang AND l2.k1 = v.valeur)' ELSE N'' END
                     + N';';
            EXEC sp_executesql @sql, N'@c SYSNAME, @num INT', @c = @col, @num = @num;
            FETCH NEXT FROM c_fk INTO @col, @cible, @col_cible, @num;
        END;
        CLOSE c_fk;
        DEALLOCATE c_fk;
        SET @r = NULL;
        SELECT TOP (1) @r = v.rang, @num = v.erreur,
               @x = N'la colonne « ' + c.libelle + N' » vaut « ' + ISNULL(v.aff, N'') + N' », qui n’est pas une ligne du référentiel « '
                  + dbo.fn_e5_libelle_referentiel(c.fk_cible) + N' ».'
        FROM #val v JOIN #col c ON c.colonne = v.colonne
        WHERE v.erreur IS NOT NULL ORDER BY v.rang, c.column_id;
        IF @r IS NOT NULL
        BEGIN
            SELECT @m = l.pfx + @x + N' Aucune ligne n’est écrite.' FROM #lig l WHERE l.rang = @r;
            EXEC dbo.pr_e5_refuser @num, @m;
        END;
        -- 9. les regles des lignes connues (n° 11) : colonne qui ne se modifie pas, colonne obligatoire videe, adresse
        --    d'installation et seuil d'un parametre, validation d'une question par l'associe seul
        SET @r = NULL;
        SELECT TOP (1) @r = v.rang, @x = N'modification refusée sur « ' + c.libelle + N' » : '
               + CASE c.famille WHEN 'ECART' THEN N'elle se pose par « Écarter la ligne »' WHEN 'PARAM' THEN N'seule la valeur se modifie : les codes des paramètres sont fixés par l’outil' ELSE N'colonne calculée ou citation d’un texte' END + N'.'
        FROM #val v JOIN #col c ON c.colonne = v.colonne JOIN #lig l ON l.rang = v.rang AND l.existe = 1
        WHERE v.change = 1 AND c.famille IN ('ECART', 'PARAM', 'FIGEE')
        ORDER BY v.rang, c.column_id;
        IF @r IS NOT NULL
        BEGIN
            SELECT @m = l.pfx + @x + N' Aucune ligne n’est écrite.' FROM #lig l WHERE l.rang = @r;
            EXEC dbo.pr_e5_refuser 50915, @m;
        END;
        SET @r = NULL;
        SELECT TOP (1) @r = v.rang, @x = N'la colonne « ' + c.libelle + N' » est vide, et elle ne reste pas vide.'
        FROM #val v JOIN #col c ON c.colonne = v.colonne JOIN #lig l ON l.rang = v.rang AND l.existe = 1
        WHERE v.change = 1 AND v.valeur IS NULL AND c.nullable = 0
        ORDER BY v.rang, c.column_id;
        IF @r IS NOT NULL
        BEGIN
            SELECT @m = l.pfx + @x + N' Aucune ligne n’est écrite.' FROM #lig l WHERE l.rang = @r;
            EXEC dbo.pr_e5_refuser 50912, @m;
        END;
        IF @t = 'ref_parametre'
        BEGIN
            SET @r = NULL;
            SELECT TOP (1) @r = l.rang, @x = N'modification refusée sur « ' + ISNULL(l.nom, l.k1) + N' » : adresse d’installation, non modifiable.'
            FROM #lig l JOIN #val v ON v.rang = l.rang AND v.colonne = N'valeur' AND v.change = 1
            WHERE l.existe = 1 AND ISNULL(dbo.fn_e5_genre_parametre(l.k1), '') <> 'SEUIL'
            ORDER BY l.rang;
            IF @r IS NOT NULL
            BEGIN
                SELECT @m = l.pfx + @x + N' Aucune ligne n’est écrite.' FROM #lig l WHERE l.rang = @r;
                EXEC dbo.pr_e5_refuser 50915, @m;
            END;
            SET @r = NULL;
            SELECT TOP (1) @r = l.rang, @x = N'la colonne « ' + c.libelle + N' » vaut « ' + ISNULL(v.aff, N'') + N' » : un seuil des paramètres du cabinet est un nombre entier positif ou nul.'
            FROM #lig l JOIN #val v ON v.rang = l.rang AND v.colonne = N'valeur' AND v.change = 1 JOIN #col c ON c.colonne = v.colonne
            WHERE l.existe = 1 AND dbo.fn_e5_genre_parametre(l.k1) = 'SEUIL' AND (v.valeur IS NULL OR v.valeur LIKE N'%[^0-9]%' OR LEN(v.valeur) > 9)
            ORDER BY l.rang;
            IF @r IS NOT NULL
            BEGIN
                SELECT @m = l.pfx + @x + N' Aucune ligne n’est écrite.' FROM #lig l WHERE l.rang = @r;
                EXEC dbo.pr_e5_refuser 50912, @m;
            END;
        END;
        IF @t = 'ref_question' AND NOT EXISTS (SELECT 1 FROM dbo.role_mission rm WHERE rm.connexion = @par AND rm.role = 'ASSOCIE'
                                                 AND rm.du <= CAST(SYSUTCDATETIME() AS DATE) AND (rm.au IS NULL OR rm.au > CAST(SYSUTCDATETIME() AS DATE)))
        BEGIN
            SET @r = NULL;
            SELECT TOP (1) @r = v.rang, @x = N'modification refusée sur « ' + c.libelle + N' » : réservé à l’associé ; seul l’associé valide une question de référence.'
            FROM #val v JOIN #col c ON c.colonne = v.colonne JOIN #lig l ON l.rang = v.rang AND l.existe = 1
            WHERE v.colonne = N'statut' AND v.change = 1 AND v.valeur = N'VALIDEE'
            ORDER BY v.rang;
            IF @r IS NOT NULL
            BEGIN
                SELECT @m = l.pfx + @x + N' Aucune ligne n’est écrite.' FROM #lig l WHERE l.rang = @r;
                EXEC dbo.pr_e5_refuser 50915, @m;
            END;
        END;
        -- 10. les regles des lignes neuves (n° 12) : ajout permis, colonnes qu'une ligne neuve laisse vides, colonnes
        --     obligatoires, article d'une reference
        IF EXISTS (SELECT 1 FROM #lig WHERE neuve = 1)
        BEGIN
            IF @actions IN (0, 2, 3)
            BEGIN
                SELECT TOP (1) @m = l.pfx + N'ajout refusé sur « ' + @lib + N' » : '
                       + CASE @actions WHEN 0 THEN N'seule la valeur se modifie : les codes des paramètres sont fixés par l’outil' WHEN 2 THEN N'un contrôle de cohérence est un calcul programmé dans l’outil, qui ne s’ajoute pas à l’écran' ELSE N'une question de référence s’ajoute à la Révision, ou à l’étape 3 pour une question sur la tenue de la comptabilité' END
                       + N'. Aucune ligne n’est écrite.'
                FROM #lig l WHERE l.neuve = 1 ORDER BY l.rang;
                EXEC dbo.pr_e5_refuser 50916, @m;
            END;
            SET @r = NULL;
            SELECT TOP (1) @r = v.rang, @x = N'la colonne « ' + c.libelle + N' » ne se saisit pas pour une ligne neuve : '
                   + CASE c.famille WHEN 'ECART' THEN N'elle se pose par « Écarter la ligne »' WHEN 'PARAM' THEN N'seule la valeur se modifie : les codes des paramètres sont fixés par l’outil' ELSE N'colonne calculée ou citation d’un texte' END + N'.'
            FROM #val v JOIN #col c ON c.colonne = v.colonne JOIN #lig l ON l.rang = v.rang AND l.neuve = 1
            WHERE v.valeur IS NOT NULL AND c.famille IN ('ECART', 'PARAM', 'FIGEE')
            ORDER BY v.rang, c.column_id;
            IF @r IS NOT NULL
            BEGIN
                SELECT @m = l.pfx + @x + N' Aucune ligne n’est écrite.' FROM #lig l WHERE l.rang = @r;
                EXEC dbo.pr_e5_refuser 50915, @m;
            END;
            SET @r = NULL;
            SELECT TOP (1) @r = l.rang, @x = N'la colonne « ' + c.libelle + N' » est vide : une ligne neuve la porte.'
            FROM #lig l JOIN #col c ON c.nullable = 0 AND c.identite = 0 AND c.calculee = 0 AND c.defaut = 0 AND c.rang_cle IS NULL
                 AND c.famille NOT IN ('HORO', 'HORS') AND c.colonne <> N'ordre' AND NOT (@t = 'ref_reference' AND c.colonne = N'intitule')
            WHERE l.neuve = 1 AND NOT EXISTS (SELECT 1 FROM #val v WHERE v.rang = l.rang AND v.colonne = c.colonne AND v.valeur IS NOT NULL)
            ORDER BY l.rang, c.column_id;
            IF @r IS NOT NULL
            BEGIN
                SELECT @m = l.pfx + @x + N' Aucune ligne n’est écrite.' FROM #lig l WHERE l.rang = @r;
                EXEC dbo.pr_e5_refuser 50912, @m;
            END;
        END;
        -- une reference normative neuve, ou dont la norme ou la reference change, s'inscrit avec l'intitule de son article
        -- (D29 de l'existant) : article absent du referentiel des articles, refus
        IF @t = 'ref_reference'
        BEGIN
            SET @r = NULL;
            SELECT TOP (1) @r = l.rang,
                   @x = N'l’article « ' + ISNULL(CAST(z.ref AS NVARCHAR (60)), N'') + N' » de la norme « ' + ISNULL(CAST(z.nor AS NVARCHAR (40)), N'')
                      + N' » n’est pas au référentiel des articles avec son intitulé ; aucun intitulé d’article ne se saisit à la main.'
            FROM #lig l
            LEFT JOIN dbo.ref_reference rr ON l.existe = 1 AND rr.id = TRY_CAST(l.k1 AS INT)
            OUTER APPLY (SELECT v.valeur FROM #val v WHERE v.rang = l.rang AND v.colonne = N'reference' AND (l.neuve = 1 OR v.change = 1)) vr
            OUTER APPLY (SELECT v.valeur FROM #val v WHERE v.rang = l.rang AND v.colonne = N'norme' AND (l.neuve = 1 OR v.change = 1)) vn
            CROSS APPLY (SELECT CASE WHEN l.neuve = 1 THEN vr.valeur ELSE COALESCE(vr.valeur, rr.reference) END AS ref,
                                CASE WHEN l.neuve = 1 THEN vn.valeur ELSE COALESCE(vn.valeur, rr.norme) END AS nor) z
            WHERE (l.neuve = 1 OR EXISTS (SELECT 1 FROM #val v WHERE v.rang = l.rang AND v.colonne IN (N'norme', N'reference') AND v.change = 1))
              AND NOT EXISTS (SELECT 1 FROM dbo.ref_article a WHERE a.article = z.ref AND a.norme = z.nor AND NULLIF(LTRIM(RTRIM(a.intitule)), N'') IS NOT NULL)
            ORDER BY l.rang;
            IF @r IS NOT NULL
            BEGIN
                SELECT @m = l.pfx + @x + N' Aucune ligne n’est écrite.' FROM #lig l WHERE l.rang = @r;
                EXEC dbo.pr_e5_refuser 50919, @m;
            END;
        END;
        -- 11. rien a ecrire : le message le dit, sans transaction
        SELECT @modifiees = SUM(CASE WHEN existe = 1 AND change = 1 THEN 1 ELSE 0 END), @ajoutees = SUM(CASE WHEN neuve = 1 THEN 1 ELSE 0 END),
               @inchangees = SUM(CASE WHEN existe = 1 AND change = 0 THEN 1 ELSE 0 END)
        FROM #lig;
        IF @modifiees + @ajoutees = 0
        BEGIN
            SET @message = N'Aucune modification : ' + CAST(@inchangees AS NVARCHAR (12)) + CASE WHEN @inchangees > 1 THEN N' lignes' ELSE N' ligne' END
                         + N' du classeur « ' + @f + N' » ' + CASE WHEN @inchangees > 1 THEN N'portent' ELSE N'porte' END
                         + N' déjà les valeurs du référentiel « ' + @lib + N' ».';
            EXEC dbo.pr_poser_message_ecran @pour = @par, @message = @message, @genre = 'SUCCES', @entite = '-', @procedure_nom = @proc;
            EXEC sp_set_session_context N'par', NULL;
            SELECT CAST('-' AS VARCHAR (20)) AS entite, @message AS message, 0 AS lignes_modifiees, 0 AS lignes_ajoutees, @inchangees AS lignes_inchangees;
            RETURN;
        END;
        -- 12. l'ecriture, ligne a ligne dans l'ordre du classeur, tout ou rien
        IF EXISTS (SELECT 1 FROM #lig WHERE neuve = 1)
        BEGIN
            SELECT @groupe_o = NULL, @groupe_n = NULL, @k = NULL;
            IF @t = 'ref_piece_attendue'
                SELECT @groupe_o = N'COALESCE(NULLIF(o.[cycle], N''''), NULLIF(o.[phase], N''''), N'''')',
                       @groupe_n = N'COALESCE(NULLIF(CAST((SELECT x.valeur FROM #val x WHERE x.rang = @r AND x.colonne = N''cycle'') AS '
                                 + (SELECT c.type_sql FROM #col c WHERE c.colonne = N'cycle') + N'), N''''), NULLIF(CAST((SELECT x.valeur FROM #val x WHERE x.rang = @r AND x.colonne = N''phase'') AS '
                                 + (SELECT c.type_sql FROM #col c WHERE c.colonne = N'phase') + N'), N''''), N'''')';
            ELSE
            BEGIN
                SELECT TOP (1) @k = i.name FROM sys.indexes i
                JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 0
                JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
                WHERE i.object_id = @oid AND i.is_unique = 1 AND c.name = N'ordre'
                  AND NOT EXISTS (SELECT 1 FROM sys.index_columns ic2 JOIN sys.columns c2 ON c2.object_id = ic2.object_id AND c2.column_id = ic2.column_id
                                  WHERE ic2.object_id = i.object_id AND ic2.index_id = i.index_id AND c2.is_identity = 1)
                ORDER BY i.index_id;
                IF @k IS NOT NULL
                    SELECT @groupe_o = STRING_AGG(CAST(N'o.' + QUOTENAME(g.colonne) AS NVARCHAR (MAX)), N', ') WITHIN GROUP (ORDER BY g.ko),
                           @groupe_n = STRING_AGG(CAST(CASE WHEN g.rang_cle IS NOT NULL THEN N'CAST(l.k' + CAST(g.rang_cle AS NVARCHAR (1)) + N' AS ' + g.type_sql + N')'
                                                           ELSE N'CAST((SELECT x.valeur FROM #val x WHERE x.rang = @r AND x.colonne = N''' + REPLACE(g.colonne, N'''', N'''''') + N''') AS ' + g.type_sql + N')' END
                                                      AS NVARCHAR (MAX)), N', ') WITHIN GROUP (ORDER BY g.ko)
                    FROM (SELECT cc.colonne, cc.rang_cle, cc.type_sql, ic.key_ordinal AS ko FROM sys.indexes i
                          JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 0
                          JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
                          JOIN #col cc ON cc.colonne = c.name COLLATE DATABASE_DEFAULT
                          WHERE i.object_id = @oid AND i.name = @k AND c.name <> N'ordre') g;
            END;
        END;
        BEGIN TRANSACTION;
        DECLARE c_ecrit CURSOR LOCAL FAST_FORWARD FOR SELECT l.rang, l.neuve FROM #lig l WHERE l.neuve = 1 OR l.change = 1 ORDER BY l.rang;
        OPEN c_ecrit;
        FETCH NEXT FROM c_ecrit INTO @rang_ecrit, @neuve;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF @neuve = 0
            BEGIN
                SET @reset = CASE WHEN @t = 'ref_reference' AND EXISTS (SELECT 1 FROM #val v WHERE v.rang = @rang_ecrit AND v.colonne IN (N'norme', N'reference') AND v.change = 1)
                                  THEN 1 ELSE 0 END;
                SET @set = NULL;
                SELECT @set = STRING_AGG(CAST(QUOTENAME(c.colonne) + N' = CAST((SELECT x.valeur FROM #val x WHERE x.rang = @r AND x.colonne = N'''
                                                  + REPLACE(c.colonne, N'''', N'''''') + N''') AS ' + c.type_sql + N')' AS NVARCHAR (MAX)), N', ')
                                  WITHIN GROUP (ORDER BY c.column_id)
                    FROM #col c
                    WHERE EXISTS (SELECT 1 FROM #val v WHERE v.rang = @rang_ecrit AND v.colonne = c.colonne AND v.change = 1)
                      AND NOT (@reset = 1 AND c.colonne IN (N'intitule', N'citation', N'lu_sur_piece', N'page_piece', N'piece_reference', N'lu_le'));
                    IF @reset = 1
                        SET @set = ISNULL(@set + N', ', N'') + N'[intitule] = (SELECT TOP (1) a.intitule FROM dbo.ref_article a WHERE a.article = '
                                 + N'COALESCE((SELECT CAST(x.valeur AS ' + @type_ref + N') FROM #val x WHERE x.rang = @r AND x.colonne = N''reference'' AND x.change = 1), t.[reference])'
                                 + N' AND a.norme = COALESCE((SELECT CAST(x.valeur AS ' + @type_norme + N') FROM #val x WHERE x.rang = @r AND x.colonne = N''norme'' AND x.change = 1), t.[norme])), '
                                 + N'[citation] = NULL, [lu_sur_piece] = 0, [page_piece] = NULL, [piece_reference] = NULL, [lu_le] = NULL';
                    SET @sql = N'UPDATE t SET ' + @set + N' FROM dbo.' + QUOTENAME(@t) + N' AS t JOIN #lig l ON l.rang = @r AND ' + @j_tl + N';';
                EXEC sp_executesql @sql, N'@r INT', @r = @rang_ecrit;
            END
            ELSE
            BEGIN
                SELECT @cols = NULL, @exprs = NULL, @id = NULL;
                SELECT @cols = STRING_AGG(CAST(QUOTENAME(c.colonne) AS NVARCHAR (MAX)), N', ') WITHIN GROUP (ORDER BY c.column_id),
                           @exprs = STRING_AGG(CAST(
                               CASE WHEN c.rang_cle IS NOT NULL THEN N'CAST(l.k' + CAST(c.rang_cle AS NVARCHAR (1)) + N' AS ' + c.type_sql + N')'
                                    WHEN c.colonne IN (N'modifie_par', N'pose_par') THEN N'CAST(@par AS ' + c.type_sql + N')'
                                    WHEN c.colonne IN (N'modifie_le', N'pose_le') THEN N'CAST(SYSUTCDATETIME() AS ' + c.type_sql + N')'
                                    WHEN @t = 'ref_reference' AND c.colonne = N'intitule'
                                        THEN N'(SELECT TOP (1) a.intitule FROM dbo.ref_article a WHERE a.article = CAST((SELECT x.valeur FROM #val x WHERE x.rang = @r AND x.colonne = N''reference'') AS '
                                             + @type_ref + N') AND a.norme = CAST((SELECT x.valeur FROM #val x WHERE x.rang = @r AND x.colonne = N''norme'') AS ' + @type_norme + N'))'
                                    WHEN c.colonne = N'ordre'
                                        THEN N'ISNULL(CAST((SELECT x.valeur FROM #val x WHERE x.rang = @r AND x.colonne = N''ordre'') AS ' + c.type_sql
                                             + N'), ISNULL((SELECT MAX(o.[ordre]) FROM dbo.' + QUOTENAME(@t) + N' AS o'
                                             + ISNULL(N' WHERE EXISTS (SELECT ' + @groupe_o + N' INTERSECT SELECT ' + @groupe_n + N')', N'') + N'), 0) + 1)'
                                    ELSE N'CAST((SELECT x.valeur FROM #val x WHERE x.rang = @r AND x.colonne = N''' + REPLACE(c.colonne, N'''', N'''''') + N''') AS ' + c.type_sql + N')' END
                               AS NVARCHAR (MAX)), N', ') WITHIN GROUP (ORDER BY c.column_id)
                    FROM #col c
                    WHERE c.calculee = 0 AND c.identite = 0
                      AND (c.rang_cle IS NOT NULL OR c.famille = 'HORO' OR c.colonne = N'ordre' OR (@t = 'ref_reference' AND c.colonne = N'intitule')
                           OR EXISTS (SELECT 1 FROM #val v WHERE v.rang = @rang_ecrit AND v.colonne = c.colonne AND v.valeur IS NOT NULL));
                    SET @sql = N'INSERT INTO dbo.' + QUOTENAME(@t) + N' (' + @cols + N') SELECT ' + @exprs + N' FROM #lig l WHERE l.rang = @r; SET @id = SCOPE_IDENTITY();';
                EXEC sp_executesql @sql, N'@r INT, @par NVARCHAR (400), @id INT OUTPUT', @r = @rang_ecrit, @par = @par, @id = @id OUTPUT;
                IF @numerotee = 1
                    UPDATE #lig SET canon = CAST(@id AS NVARCHAR (12)), canon2 = CAST(@id AS NVARCHAR (12)) WHERE rang = @rang_ecrit;
            END;
            FETCH NEXT FROM c_ecrit INTO @rang_ecrit, @neuve;
        END;
        CLOSE c_ecrit;
        DEALLOCATE c_ecrit;
        SET @rang_ecrit = NULL;
        -- 13. la designation de chaque ligne ecrite reste unique dans son referentiel (B13), relue apres l'ecriture ; une
        --     designation inchangee ne se refuse pas (un doublon anterieur ne vient pas de ce reimport)
        INSERT INTO #des (apres, cle, ligne) SELECT 1, d.cle, d.ligne FROM dbo.v_ecran_referentiel_lignes d WHERE d.referentiel = @t OPTION (RECOMPILE);
        SET @r = NULL;
        SELECT TOP (1) @r = l.rang, @x = LEFT(d1.ligne, 400)
        FROM #lig l
        CROSS APPLY (SELECT TOP (1) x.ligne FROM #des x WHERE x.apres = 1 AND x.cle IN (l.canon, l.canon2)) d1
        WHERE (l.neuve = 1 OR l.change = 1)
          AND (l.neuve = 1 OR l.avant IS NULL OR l.avant <> d1.ligne)
          AND (SELECT COUNT(*) FROM #des d2 WHERE d2.apres = 1 AND d2.ligne = d1.ligne) > 1
        ORDER BY l.rang;
        IF @r IS NOT NULL
        BEGIN
            SELECT @m = l.pfx + N'la ligne porterait la désignation « ' + @x + N' », déjà celle d’une autre ligne du référentiel « ' + @lib
                      + N' » ; chaque ligne y porte une désignation distincte. Aucune ligne n’est écrite.'
            FROM #lig l WHERE l.rang = @r;
            EXEC dbo.pr_e5_refuser 50917, @m;
        END;
        SET @message = N'Classeur « ' + @f + N' » réimporté dans « ' + @lib + N' » : '
                     + CAST(@modifiees AS NVARCHAR (12)) + CASE WHEN @modifiees > 1 THEN N' lignes modifiées, ' ELSE N' ligne modifiée, ' END
                     + CAST(@ajoutees AS NVARCHAR (12)) + CASE WHEN @ajoutees > 1 THEN N' lignes ajoutées, ' ELSE N' ligne ajoutée, ' END
                     + CAST(@inchangees AS NVARCHAR (12)) + CASE WHEN @inchangees > 1 THEN N' lignes inchangées.' ELSE N' ligne inchangée.' END;
        EXEC dbo.pr_poser_message_ecran @pour = @par, @message = @message, @genre = 'SUCCES', @entite = '-', @procedure_nom = @proc;
        COMMIT TRANSACTION;
        EXEC sp_set_session_context N'par', NULL;
        SELECT CAST('-' AS VARCHAR (20)) AS entite, @message AS message, @modifiees AS lignes_modifiees, @ajoutees AS lignes_ajoutees,
               @inchangees AS lignes_inchangees;
    END TRY
    BEGIN CATCH
        SELECT @e_num = ERROR_NUMBER(), @e_msg = ERROR_MESSAGE(), @pfx = NULL, @num = NULL;
        -- la ligne en cours d'ecriture, lue avant le rollback : sous une Data function, le rollback emporte les tables #
        IF @rang_ecrit IS NOT NULL AND OBJECT_ID(N'tempdb..#lig') IS NOT NULL
            SELECT @pfx = l.pfx FROM #lig l WHERE l.rang = @rang_ecrit;
        IF @tc = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        BEGIN TRY EXEC sp_set_session_context N'par', NULL; END TRY BEGIN CATCH END CATCH;
        -- une contrainte de la table a l'ecriture d'une ligne : en francais, par le libelle de la colonne, jamais par le
        -- nom de la contrainte (CHECK 50918, cle etrangere 50914, unicite 50917, NULL 50912)
        SET @e_fr = dbo.fn_e5_traduire_erreur(@e_num, @e_msg);
        SET @num = CASE WHEN @e_num IN (2601, 2627) THEN 50917 WHEN @e_num = 547 AND @e_msg LIKE N'%CHECK constraint%' THEN 50918
                        WHEN @e_num = 547 THEN 50914 WHEN @e_num = 515 THEN 50912 END;
        IF @e_fr IS NULL AND @e_num = 515
        BEGIN
            SET @i = CHARINDEX(N'column ''', @e_msg);
            SET @c = CASE WHEN @i > 0 AND CHARINDEX(N'''', @e_msg, @i + 8) > @i + 8 THEN SUBSTRING(@e_msg, @i + 8, CHARINDEX(N'''', @e_msg, @i + 8) - @i - 8) END;
            SET @e_fr = N'Valeur refusée : la colonne « ' + ISNULL(dbo.fn_e5_libelle_colonne(@t, @c), N'obligatoire') + N' » du référentiel « '
                      + ISNULL(@lib, N'') + N' » ne reste pas vide.';
        END;
        -- un refus de garde (ROLLBACK, inscription, THROW, objet n° 17) recu sous 266 ou 3609 : la ligne qu'un declencheur
        -- a inscrite pour @par depuis l'entree
        IF @e_fr IS NULL AND @e_num IN (266, 3609) AND @par IS NOT NULL
            SELECT TOP (1) @e_fr = j.message, @num = 50928 FROM dbo.journal_refus j
            WHERE j.id > @journal_avant AND j.procedure_nom LIKE 'tr[_]%' AND j.refuse_pour = LEFT(@par, 200)
            ORDER BY j.id DESC;
        -- un refus d'un declencheur a l'ecriture d'une ligne (garde, statut d'une question, reference abrogee) : sa ligne
        IF @e_fr IS NULL AND @e_num >= 50000 AND @pfx IS NOT NULL
            SELECT @e_fr = @e_msg, @num = @e_num;
        IF @e_fr IS NOT NULL
            SET @e_fr = ISNULL(@pfx, N'Réimport refusé : ')
                      + CASE WHEN LEFT(@e_fr, 17) = N'Valeur refusée : ' THEN SUBSTRING(@e_fr, 18, 2000) ELSE @e_fr END
                      + N' Aucune ligne n’est écrite.';
        SET @e_journal = ISNULL(@e_fr, @e_msg);
        EXEC dbo.pr_e5_conclure_refus @tc, @journal_avant, @proc, @par, '-', @e_journal;
        IF @e_fr IS NOT NULL
        BEGIN
            SET @num = ISNULL(@num, 50928);
            EXEC dbo.pr_e5_refuser @num, @e_fr;
        END;
        THROW;
    END CATCH;
END;

GO

