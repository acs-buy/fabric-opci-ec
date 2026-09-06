
         CREATE PROCEDURE [a17b18e9-b7f7-4bd9-b911-cf436bc66b7a].[sp_powertable_hard_delete]
(
    @RootTable     NVARCHAR(MAX),
    @RootPkValues  NVARCHAR(MAX) = NULL,
    @RootWhere     NVARCHAR(MAX) = NULL,
    @DeleteGraph   NVARCHAR(MAX),
    @SchemaName   NVARCHAR(MAX)
)
AS
BEGIN
    SET NOCOUNT ON;

    IF(
         (@RootPkValues IS NULL OR LTRIM(RTRIM(@RootPkValues)) = '')
        AND
        (@RootWhere IS NULL OR LTRIM(RTRIM(@RootWhere)) = '')
    )
    BEGIN
         THROW 50001, 'Hard delete failed: Either @RootPkValues or @RootWhere must be provided.', 1;
    END;

    BEGIN TRY
        BEGIN TRAN;

        /* ================================
           1. RELATIONS TABLE
        ================================= */
        CREATE TABLE #Relations
        (
            parentTable NVARCHAR(MAX) NOT NULL,
            childTable  NVARCHAR(MAX) NOT NULL,
            childFk     NVARCHAR(MAX) NOT NULL,
            level       INT,
            isActive    BIT NOT NULL DEFAULT 0
        );

        INSERT INTO #Relations (parentTable, childTable, childFk)
        SELECT parent, child, childFk
        FROM OPENJSON(@DeleteGraph)
        WITH
        (
            parent   NVARCHAR(MAX) '$.parent',
            child    NVARCHAR(MAX) '$.child',
            childFk  NVARCHAR(MAX) '$.childFk'
        );

        /* ================================
           2. ACTIVATE ROOT
        ================================= */
        UPDATE #Relations
        SET isActive = 1, level = 1
        WHERE parentTable = @RootTable;

        WHILE EXISTS
        (
            SELECT 1
            FROM #Relations r
            JOIN #Relations p ON r.parentTable = p.childTable
            WHERE r.isActive = 0 AND p.isActive = 1
        )
        BEGIN
            UPDATE r
            SET r.isActive = 1,
                r.level = p.level + 1
            FROM #Relations r
            JOIN #Relations p ON r.parentTable = p.childTable
            WHERE r.isActive = 0 AND p.isActive = 1;
        END;

        /* ================================
           3. DELETE SET
        ================================= */
        CREATE TABLE #DeleteSet
        (
            TableName NVARCHAR(MAX) NOT NULL,
            PkValue   NVARCHAR(MAX) NOT NULL
        );

        DECLARE @sql NVARCHAR(MAX);

        IF @RootPkValues IS NOT NULL
        BEGIN
            INSERT INTO #DeleteSet
            SELECT @RootTable, CAST([value] AS NVARCHAR(MAX))
            FROM OPENJSON(@RootPkValues);
        END
        ELSE
        BEGIN
            SET @sql = N'
INSERT INTO #DeleteSet
SELECT ''' + @RootTable + ''', CAST(id AS NVARCHAR(MAX))
FROM ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@RootTable) + '
WHERE ' + @RootWhere;

            EXEC (@sql);
        END;

        /* ================================
           4. BUILD DELETE SET
        ================================= */
        DECLARE
            @pTable NVARCHAR(MAX),
            @cTable NVARCHAR(MAX),
            @cFk    NVARCHAR(MAX);

        DECLARE rel_cur CURSOR FOR
        SELECT parentTable, childTable, childFk
        FROM #Relations
        WHERE isActive = 1
        ORDER BY level;

        OPEN rel_cur;
        FETCH NEXT FROM rel_cur INTO @pTable, @cTable, @cFk;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @sql = N'
INSERT INTO #DeleteSet
SELECT DISTINCT ''' + @cTable + ''', CAST(c.id AS NVARCHAR(MAX))
FROM ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@cTable) + ' c
JOIN #DeleteSet d
  ON d.TableName = ''' + @pTable + '''
 AND c.' + QUOTENAME(@cFk) + ' = d.PkValue';

            EXEC (@sql);
            FETCH NEXT FROM rel_cur INTO @pTable, @cTable, @cFk;
        END;

        CLOSE rel_cur;
        DEALLOCATE rel_cur;

        /* ================================
           5. DELETE CHILDREN
        ================================= */
        DECLARE
            @tbl NVARCHAR(MAX),
            @fk  NVARCHAR(MAX),
            @par NVARCHAR(MAX);

        DECLARE del_cur CURSOR FOR
        SELECT childTable, childFk, parentTable
        FROM #Relations
        WHERE isActive = 1
        ORDER BY level DESC;

        OPEN del_cur;
        FETCH NEXT FROM del_cur INTO @tbl, @fk, @par;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @sql = N'
DELETE FROM ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@tbl) + '
WHERE ' + QUOTENAME(@fk) + ' IN
(
    SELECT PkValue FROM #DeleteSet
    WHERE TableName = ''' + @par + '''
);';

            EXEC (@sql);
            FETCH NEXT FROM del_cur INTO @tbl, @fk, @par;
        END;

        CLOSE del_cur;
        DEALLOCATE del_cur;

        /* ================================
           6. DELETE ROOT
        ================================= */
        SET @sql = N'
DELETE FROM ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@RootTable) + '
WHERE id IN
(
    SELECT PkValue FROM #DeleteSet
    WHERE TableName = ''' + @RootTable + '''
);';

        EXEC (@sql);

        COMMIT;
    END TRY
    BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;

    DECLARE @err NVARCHAR(MAX) = ERROR_MESSAGE();
    DECLARE @line NVARCHAR(MAX) = CAST(ERROR_LINE() AS NVARCHAR(MAX));
    DECLARE @msg NVARCHAR(MAX);

    SET @msg =
        'Hard delete failed at line ' + @line + ': ' + @err;

    THROW 50000, @msg, 1;
END CATCH
END;

GO

