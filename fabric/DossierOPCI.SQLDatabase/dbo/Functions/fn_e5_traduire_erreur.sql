-- ------------------------------------------------------------------ les erreurs 547, 2601 et 2627 en francais, la colonne nommee par son libelle
-- ecran 5, lot 1, script 323 (61_DEPLOIEMENT/generer_e5_323_procedures_de_tenue.py)
-- Jamais le nom de la contrainte : la colonne par son libelle (ref_libelle_colonne), le referentiel par son nom au
-- registre ; NULL pour une autre erreur, que la procedure releve telle quelle.
CREATE   FUNCTION dbo.fn_e5_traduire_erreur (@numero INT, @message NVARCHAR (4000))
RETURNS NVARCHAR (2000)
AS
BEGIN
    IF @numero NOT IN (547, 2601, 2627) OR @message IS NULL RETURN NULL;
    DECLARE @nom SYSNAME, @i INT, @j INT, @table VARCHAR (120), @cible VARCHAR (120), @colonnes NVARCHAR (1000),
            @n INT, @valeur NVARCHAR (400), @admises NVARCHAR (1000), @objet NVARCHAR (300);
    IF @numero = 547
    BEGIN
        SET @i = CHARINDEX(N'constraint "', @message);
        IF @i = 0 RETURN NULL;
        SET @i = @i + 12;
        SET @j = CHARINDEX(N'"', @message, @i);
        IF @j = 0 RETURN NULL;
        SET @nom = SUBSTRING(@message, @i, @j - @i);
        IF EXISTS (SELECT 1 FROM sys.check_constraints k WHERE k.name = @nom)
        BEGIN
            SELECT TOP (1) @table = OBJECT_NAME(k.parent_object_id) FROM sys.check_constraints k WHERE k.name = @nom;
            SELECT @n = COUNT(*),
                   @colonnes = STRING_AGG(CAST(N'« ' + dbo.fn_e5_libelle_colonne(@table, c.name) + N' »' AS NVARCHAR (MAX)), N', ')
                               WITHIN GROUP (ORDER BY c.column_id)
            FROM sys.check_constraints k JOIN sys.columns c ON c.object_id = k.parent_object_id
            WHERE k.name = @nom AND (c.column_id = k.parent_column_id
                                     OR (k.parent_column_id = 0 AND CHARINDEX(QUOTENAME(c.name), k.definition) > 0));
            IF @n = 1
                SELECT @admises = STRING_AGG(CAST(N'« ' + v.libelle + N' »' AS NVARCHAR (MAX)), N', ') WITHIN GROUP (ORDER BY v.libelle)
                FROM sys.check_constraints k
                JOIN sys.columns c ON c.object_id = k.parent_object_id AND c.column_id = k.parent_column_id
                JOIN dbo.ref_libelle_valeur v ON v.table_nom = @table AND v.colonne = c.name COLLATE DATABASE_DEFAULT
                WHERE k.name = @nom;
            IF @n = 1
                RETURN N'Valeur refusée : la colonne ' + @colonnes + N' du référentiel « ' + dbo.fn_e5_libelle_referentiel(@table)
                     + N' » n’admet pas cette valeur' + ISNULL(N' ; valeurs admises : ' + @admises, N'') + N'.';
            RETURN N'Valeur refusée : les colonnes ' + ISNULL(@colonnes, N'de la ligne') + N' du référentiel « '
                 + dbo.fn_e5_libelle_referentiel(@table) + N' » ne s’accordent pas entre elles : la valeur saisie contredit une autre colonne de la ligne.';
        END;
        IF EXISTS (SELECT 1 FROM sys.foreign_keys fk WHERE fk.name = @nom)
        BEGIN
            SELECT TOP (1) @table = OBJECT_NAME(fk.parent_object_id), @cible = OBJECT_NAME(fk.referenced_object_id)
            FROM sys.foreign_keys fk WHERE fk.name = @nom;
            SELECT @colonnes = STRING_AGG(CAST(N'« ' + dbo.fn_e5_libelle_colonne(@table, c.name) + N' »' AS NVARCHAR (MAX)), N', ')
            FROM sys.foreign_keys fk
            JOIN sys.foreign_key_columns fc ON fc.constraint_object_id = fk.object_id
            JOIN sys.columns c ON c.object_id = fc.parent_object_id AND c.column_id = fc.parent_column_id
            WHERE fk.name = @nom;
            IF CHARINDEX(N'REFERENCE constraint', @message) > 0
                RETURN N'Écriture refusée : la ligne est employée par '
                     + CASE WHEN EXISTS (SELECT 1 FROM dbo.ref_referentiel r WHERE r.table_nom = @table)
                            THEN N'le référentiel « ' + dbo.fn_e5_libelle_referentiel(@table) + N' » (colonne ' + ISNULL(@colonnes, N'') + N')'
                            ELSE N'les dossiers' END
                     + N' ; une ligne employée garde son code et ne se supprime pas.';
            RETURN N'Valeur refusée : la colonne ' + ISNULL(@colonnes, N'') + N' du référentiel « ' + dbo.fn_e5_libelle_referentiel(@table)
                 + N' » attend une ligne du référentiel « ' + dbo.fn_e5_libelle_referentiel(@cible) + N' », et la valeur saisie n’en est pas une.';
        END;
        RETURN NULL;
    END;
    -- 2601 et 2627 : l'index, la table et la valeur en double, lus dans le message
    SET @i = CASE WHEN @numero = 2627 THEN CHARINDEX(N'constraint ''', @message) ELSE CHARINDEX(N'unique index ''', @message) END;
    IF @i = 0 RETURN NULL;
    SET @i = @i + CASE WHEN @numero = 2627 THEN 12 ELSE 14 END;
    SET @j = CHARINDEX(N'''', @message, @i);
    IF @j = 0 RETURN NULL;
    SET @nom = SUBSTRING(@message, @i, @j - @i);
    SET @i = CHARINDEX(N'object ''', @message);
    IF @i = 0 RETURN NULL;
    SET @i = @i + 8;
    SET @j = CHARINDEX(N'''', @message, @i);
    IF @j = 0 RETURN NULL;
    SET @objet = SUBSTRING(@message, @i, @j - @i);
    SET @table = PARSENAME(@objet, 1);
    SET @i = CHARINDEX(N'The duplicate key value is (', @message);
    IF @i > 0 AND LEN(@message) - 1 - (@i + 28) > 0
        SET @valeur = SUBSTRING(@message, @i + 28, LEN(@message) - 1 - (@i + 28));
    SELECT @n = COUNT(*),
           @colonnes = STRING_AGG(CAST(N'« ' + dbo.fn_e5_libelle_colonne(@table, c.name) + N' »' AS NVARCHAR (MAX)), N', ')
                       WITHIN GROUP (ORDER BY ic.key_ordinal)
    FROM sys.indexes i
    JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 0
    JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
    WHERE i.object_id = OBJECT_ID(N'dbo.' + QUOTENAME(@table)) AND i.name = @nom;
    IF ISNULL(@n, 0) = 0 RETURN NULL;
    RETURN N'Valeur refusée : ' + CASE WHEN @n = 1 THEN N'la colonne ' + @colonnes + N' porte déjà '
                                       ELSE N'les colonnes ' + @colonnes + N' portent déjà ' END
         + ISNULL(N'« ' + @valeur + N' »', N'cette valeur') + N' sur une autre ligne du référentiel « '
         + dbo.fn_e5_libelle_referentiel(@table) + N' » ; chaque ligne y porte une valeur distincte.';
END;

GO

