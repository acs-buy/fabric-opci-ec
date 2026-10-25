-- ------------------------------------------------------------------ une cle a la forme de la vue, en clause parametree
-- ecran 5, lot 1, script 323 (61_DEPLOIEMENT/generer_e5_323_procedures_de_tenue.py)
-- @cle : les parties jointes par « · », dans l'ordre de la cle primaire ; une partie question_id (ou la cle numerotee de
-- ref_question) recue par l'identifiant ou par la reference de la question (IMMO-11) ; une partie reference_id (ou la
-- cle numerotee de ref_reference) par l'identifiant ou par « norme reference » (CMF L214-81). Rend la clause
-- « t.[c1] = CAST(<prefixe>1 AS ...) AND ... », l'affectation « [c1] = CAST(<prefixe>1 AS ...), ... », les parties
-- converties, la cle a la forme de la vue (canon : reference_id en « norme reference », une cle numerotee en nombre),
-- l'existence de la ligne et sa designation (v_ecran_referentiel_lignes). Refuse en francais, en nommant le champ, un
-- nombre de parties faux, une partie vide, une question ou une reference inconnue, une partie qui n'est pas du type de sa
-- colonne.
CREATE   PROCEDURE dbo.pr_e5_resoudre_cle
    @table       VARCHAR (120),
    @cle         NVARCHAR (400),
    @champ       NVARCHAR (80),
    @prefixe     NVARCHAR (4),
    @clause      NVARCHAR (MAX) OUTPUT,
    @affectation NVARCHAR (MAX) OUTPUT,
    @p1          NVARCHAR (400) OUTPUT,
    @p2          NVARCHAR (400) OUTPUT,
    @canon       NVARCHAR (400) OUTPUT,
    @existe      BIT            OUTPUT,
    @ligne       NVARCHAR (400) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @oid INT = OBJECT_ID(N'dbo.' + QUOTENAME(@table)), @m NVARCHAR (2000), @nb_cles INT, @nb_parties INT,
            @i INT = 1, @col SYSNAME, @type_nom SYSNAME, @longueur INT, @identite BIT, @cible VARCHAR (20), @type NVARCHAR (60),
            @v NVARCHAR (400), @val NVARCHAR (400), @part NVARCHAR (400), @lib NVARCHAR (128), @libr NVARCHAR (160),
            @sql NVARCHAR (MAX), @params NVARCHAR (400), @nombre INT, @sep NVARCHAR (3) = N' ' + NCHAR (183) + N' ',
            @point NCHAR (1) = NCHAR (183);
    SELECT @clause = NULL, @affectation = NULL, @p1 = NULL, @p2 = NULL, @canon = NULL, @existe = 0, @ligne = NULL;
    SET @libr = dbo.fn_e5_libelle_referentiel(@table);
    DECLARE @cols TABLE (rang INT PRIMARY KEY, nom SYSNAME, type_nom SYSNAME, longueur INT, identite BIT, cible VARCHAR (20));
    INSERT INTO @cols (rang, nom, type_nom, longueur, identite, cible)
    SELECT ic.key_ordinal, c.name, TYPE_NAME(c.user_type_id),
           CASE WHEN c.max_length = -1 THEN -1 WHEN TYPE_NAME(c.user_type_id) IN (N'nvarchar', N'nchar') THEN c.max_length / 2
                ELSE c.max_length END,
           c.is_identity,
           CASE WHEN c.is_identity = 1 AND @table IN ('ref_question', 'ref_reference') THEN @table
                ELSE (SELECT TOP (1) CAST(OBJECT_NAME(fc.referenced_object_id) AS VARCHAR (20))
                      FROM sys.foreign_key_columns fc
                      JOIN sys.columns rc ON rc.object_id = fc.referenced_object_id AND rc.column_id = fc.referenced_column_id
                      WHERE fc.parent_object_id = c.object_id AND fc.parent_column_id = c.column_id AND rc.is_identity = 1
                        AND fc.referenced_object_id IN (OBJECT_ID(N'dbo.ref_question'), OBJECT_ID(N'dbo.ref_reference'))) END
    FROM sys.indexes i
    JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
    JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
    WHERE i.object_id = @oid AND i.is_primary_key = 1;
    SET @nb_cles = (SELECT COUNT(*) FROM @cols);
    IF @nb_cles NOT IN (1, 2)
    BEGIN
        SET @m = N'Action refusée : le code du référentiel « ' + @libr + N' » ne tient pas en 1 ou 2 parties, que l’écran sait lire.';
        EXEC dbo.pr_e5_refuser 50840, @m;
    END;
    DECLARE @parties TABLE (rang INT PRIMARY KEY, valeur NVARCHAR (400));
    INSERT INTO @parties (rang, valeur)
    SELECT CAST(s.ordinal AS INT), LTRIM(RTRIM(s.value)) FROM STRING_SPLIT(@cle, @point, 1) s;
    SET @nb_parties = (SELECT COUNT(*) FROM @parties);
    IF @nb_parties <> @nb_cles OR EXISTS (SELECT 1 FROM @parties WHERE valeur = N'')
    BEGIN
        SET @m = N'« ' + @champ + N' » : « ' + @cle + N' » ne se lit pas comme un code du référentiel « ' + @libr + N' », '
               + CASE WHEN @nb_cles = 1 THEN N'qui tient en une partie, « ' + ISNULL(dbo.fn_e5_forme_cle(@table), N'') + N' ».'
                      ELSE N'qui en porte 2, « ' + ISNULL(dbo.fn_e5_forme_cle(@table), N'') + N' », séparées par « ' + NCHAR (183) + N' ».' END;
        EXEC dbo.pr_e5_refuser 50840, @m;
    END;
    WHILE @i <= @nb_cles
    BEGIN
        SELECT @col = nom, @type_nom = type_nom, @longueur = longueur, @identite = identite, @cible = cible FROM @cols WHERE rang = @i;
        SELECT @v = valeur FROM @parties WHERE rang = @i;
        SELECT @lib = dbo.fn_e5_libelle_colonne(@table, @col), @type = dbo.fn_e5_type_colonne(@table, @col), @val = NULL, @part = NULL;
        IF @cible = 'ref_question'
        BEGIN
            IF @v NOT LIKE N'%[^0-9]%' AND LEN(@v) <= 9
                SELECT @val = CAST(q.id AS NVARCHAR (12)) FROM dbo.ref_question q WHERE q.id = CAST(@v AS INT);
            IF @val IS NULL
                SELECT @val = CAST(q.id AS NVARCHAR (12)) FROM dbo.ref_question q WHERE q.reference = @v;
            IF @val IS NULL
            BEGIN
                SET @m = N'« ' + @champ + N' » : la question « ' + @v + N' » n’est pas une question de référence.';
                EXEC dbo.pr_e5_refuser 50841, @m;
            END;
            SET @part = @val;
        END
        ELSE IF @cible = 'ref_reference'
        BEGIN
            IF @v NOT LIKE N'%[^0-9]%' AND LEN(@v) <= 9
                SELECT @val = CAST(r.id AS NVARCHAR (12)), @part = r.norme + N' ' + r.reference FROM dbo.ref_reference r WHERE r.id = CAST(@v AS INT);
            IF @val IS NULL
                SELECT @val = CAST(r.id AS NVARCHAR (12)), @part = r.norme + N' ' + r.reference FROM dbo.ref_reference r
                WHERE r.norme + N' ' + r.reference = @v;
            IF @val IS NULL
            BEGIN
                SET @m = N'« ' + @champ + N' » : « ' + @v + N' » n’est pas une référence normative ; elle se saisit « norme référence », comme « '
                       + ISNULL((SELECT TOP (1) r.norme + N' ' + r.reference FROM dbo.ref_reference r ORDER BY r.id), N'') + N' ».';
                EXEC dbo.pr_e5_refuser 50841, @m;
            END;
            IF @identite = 1 SET @part = @val;
        END
        ELSE IF @type_nom IN (N'tinyint', N'smallint', N'int', N'bigint')
        BEGIN
            IF @v LIKE N'%[^0-9]%' OR LEN(@v) > 18
            BEGIN
                SET @m = N'« ' + @champ + N' » : « ' + @v + N' » n’est pas un nombre entier, et la partie « ' + @lib + N' » du code en est un.';
                EXEC dbo.pr_e5_refuser 50841, @m;
            END;
            SELECT @val = CAST(CAST(@v AS BIGINT) AS NVARCHAR (20)), @part = CAST(CAST(@v AS BIGINT) AS NVARCHAR (20));
        END
        ELSE
        BEGIN
            IF @longueur <> -1 AND LEN(@v) > @longueur
            BEGIN
                SET @m = N'« ' + @champ + N' » : « ' + @v + N' » dépasse les ' + CAST(@longueur AS NVARCHAR (10)) + N' caractères de la partie « ' + @lib + N' » du code.';
                EXEC dbo.pr_e5_refuser 50841, @m;
            END;
            IF @type_nom IN (N'varchar', N'char')
               AND CAST(CAST(@v AS VARCHAR (400)) AS NVARCHAR (400)) COLLATE Latin1_General_BIN2 <> @v COLLATE Latin1_General_BIN2
            BEGIN
                SET @m = N'« ' + @champ + N' » : « ' + @v + N' » porte un caractère que la partie « ' + @lib + N' » du code n’admet pas.';
                EXEC dbo.pr_e5_refuser 50841, @m;
            END;
            SELECT @val = @v, @part = @v;
        END;
        SET @clause = ISNULL(@clause + N' AND ', N'') + N't.' + QUOTENAME(@col) + N' = CAST(' + @prefixe + CAST(@i AS NVARCHAR (1)) + N' AS ' + @type + N')';
        SET @affectation = ISNULL(@affectation + N', ', N'') + QUOTENAME(@col) + N' = CAST(' + @prefixe + CAST(@i AS NVARCHAR (1)) + N' AS ' + @type + N')';
        SET @canon = ISNULL(@canon + @sep, N'') + @part;
        IF @i = 1 SET @p1 = @val ELSE SET @p2 = @val;
        SET @i += 1;
    END;
    SET @sql = N'SELECT @nombre = COUNT(*) FROM dbo.' + QUOTENAME(@table) + N' AS t WHERE ' + @clause + N';';
    SET @params = @prefixe + N'1 NVARCHAR (400), ' + @prefixe + N'2 NVARCHAR (400), @nombre INT OUTPUT';
    EXEC sp_executesql @sql, @params, @p1, @p2, @nombre = @nombre OUTPUT;
    SET @existe = CASE WHEN @nombre > 0 THEN 1 ELSE 0 END;
    IF @existe = 1 AND OBJECT_ID(N'dbo.v_ecran_referentiel_lignes') IS NOT NULL
        SELECT TOP (1) @ligne = l.ligne FROM dbo.v_ecran_referentiel_lignes l
        WHERE l.referentiel = @table AND l.cle IN (@canon, @cle) OPTION (RECOMPILE);
    SET @ligne = ISNULL(@ligne, @canon);
END;

GO

