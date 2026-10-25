-- ------------------------------------------------------------------ l'emploi d'une ligne, par chaque cle etrangere entrante
-- ecran 5, lot 1, script 323 (61_DEPLOIEMENT/generer_e5_323_procedures_de_tenue.py)
-- La decision se prend sur ce decompte, relu en base : une ligne de la table qui emploie compte une fois, par 1 ou par 2
-- cles. Le texte est celui de v_ecran_referentiel_lignes (objet n° 6), que montre la liste ; a defaut, le decompte par
-- table. @clause est celle de pr_e5_resoudre_cle au prefixe @k.
CREATE   PROCEDURE dbo.pr_e5_emploi
    @table        VARCHAR (120),
    @clause       NVARCHAR (MAX),
    @k1           NVARCHAR (400),
    @k2           NVARCHAR (400),
    @canon        NVARCHAR (400),
    @cle          NVARCHAR (400),
    @emploi       INT            OUTPUT,
    @employee_par NVARCHAR (MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @fk TABLE (rang INT IDENTITY (1, 1) PRIMARY KEY, enfant SYSNAME, condition NVARCHAR (MAX));
    DECLARE @i INT = 1, @nb INT, @n INT, @enfant SYSNAME, @condition NVARCHAR (MAX), @sql NVARCHAR (MAX), @texte NVARCHAR (MAX);
    SELECT @emploi = 0, @employee_par = NULL;
    INSERT INTO @fk (enfant, condition)
    SELECT x.enfant, STRING_AGG(CAST(N'(' + x.cond + N')' AS NVARCHAR (MAX)), N' OR ')
    FROM (SELECT OBJECT_NAME(fk.parent_object_id) AS enfant,
                 (SELECT STRING_AGG(CAST(N'c.' + QUOTENAME(pc.name) + N' = t.' + QUOTENAME(rc.name) AS NVARCHAR (MAX)), N' AND ')
                  FROM sys.foreign_key_columns fc
                  JOIN sys.columns pc ON pc.object_id = fc.parent_object_id AND pc.column_id = fc.parent_column_id
                  JOIN sys.columns rc ON rc.object_id = fc.referenced_object_id AND rc.column_id = fc.referenced_column_id
                  WHERE fc.constraint_object_id = fk.object_id) AS cond
          FROM sys.foreign_keys fk
          WHERE fk.referenced_object_id = OBJECT_ID(N'dbo.' + QUOTENAME(@table))) x
    GROUP BY x.enfant
    ORDER BY x.enfant;
    SET @nb = (SELECT COUNT(*) FROM @fk);
    WHILE @i <= @nb
    BEGIN
        SELECT @enfant = enfant, @condition = condition FROM @fk WHERE rang = @i;
        SET @sql = N'SELECT @n = COUNT(*) FROM dbo.' + QUOTENAME(@enfant) + N' AS c WHERE EXISTS (SELECT 1 FROM dbo.'
                 + QUOTENAME(@table) + N' AS t WHERE ' + @clause + N' AND (' + @condition + N'));';
        EXEC sp_executesql @sql, N'@k1 NVARCHAR (400), @k2 NVARCHAR (400), @n INT OUTPUT', @k1, @k2, @n = @n OUTPUT;
        IF @n > 0
            SELECT @emploi += @n,
                   @texte = ISNULL(@texte + N' ' + NCHAR (183) + N' ', N'') + CAST(@n AS NVARCHAR (12))
                          + CASE WHEN @n > 1 THEN N' lignes de « ' ELSE N' ligne de « ' END + dbo.fn_e5_libelle_referentiel(@enfant) + N' »';
        SET @i += 1;
    END;
    IF @emploi > 0 AND OBJECT_ID(N'dbo.v_ecran_referentiel_lignes') IS NOT NULL
        SELECT TOP (1) @employee_par = NULLIF(l.employee_par, N'') FROM dbo.v_ecran_referentiel_lignes l
        WHERE l.referentiel = @table AND l.cle IN (@canon, @cle) OPTION (RECOMPILE);
    IF @emploi > 0 SET @employee_par = ISNULL(@employee_par, @texte);
END;

GO

