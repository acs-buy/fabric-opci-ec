
CREATE   PROCEDURE [b456ad3e-2ff7-478a-80c8-a81f7c6c841b].[sp_visual_data_delete]
    @visualIds NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    IF @visualIds IS NULL OR ISJSON(@visualIds) <> 1
        THROW 50001, 'visualIds must be a valid JSON array', 1;

    DECLARE @SCHEMA SYSNAME = 'b456ad3e-2ff7-478a-80c8-a81f7c6c841b';
    DECLARE @VisualDeleteConfig NVARCHAR(MAX) = N'
{
 "tables": [
    { "table": "planning_snapshot_job", "column": "visualId" },
    { "table": "comment", "column": "visualId" },
    { "table": "data_input_job", "column": "visualId" },
    { "table": "export_job", "column": "visualId" },
    { "table": "data_input_row_user_access", "column": "visualId" },
    { "table": "data_input_column_user_access", "column": "visualId" },
    { "table": "approval_column_user_access", "column": "visualId" },
    { "table": "forecast_user_access", "column": "visualId" },
    { "table": "scenario_user_access", "column": "visualId" },
    { "table": "writeback_user_access", "column": "visualId" },
    { "table": "writeback_scenario_status", "column": "visualId" },
    { "table": "planning_settings_audit", "column": "visualId" },
    { "table": "writeback_destination", "column": "visualId" },
    { "table": "writeback_settings", "column": "visualId" },
    { "table": "data_input_row", "column": "visualId" },
    { "table": "cube_partition_measure_data_input_column_mapping", "column": "visualId" },
    { "table": "data_input_column", "column": "visualId" },
    { "table": "planning_snapshot", "column": "visualId" },
    { "table": "scenario", "column": "visualId" },
    { "table": "writeback", "column": "visualId" }
  ]
}
';

    BEGIN TRY
        BEGIN TRANSACTION;

        /* ---------------------------------------
           Parse visualIds into temp table
        ---------------------------------------- */
        IF OBJECT_ID('tempdb..#VisualIds') IS NOT NULL
            DROP TABLE #VisualIds;

        CREATE TABLE #VisualIds (
            visualId INT PRIMARY KEY
        );

        INSERT INTO #VisualIds (visualId)
        SELECT CAST(value AS INT)
        FROM OPENJSON(@visualIds);

        /* ---------------------------------------
           Collect dynamic visual-specific tables
        ---------------------------------------- */
        IF OBJECT_ID('tempdb..#DynamicTables') IS NOT NULL
            DROP TABLE #DynamicTables;

        CREATE TABLE #DynamicTables (
            tableName SYSNAME PRIMARY KEY
        );

        INSERT INTO #DynamicTables (tableName)
        SELECT DISTINCT atm.tableName
        FROM audit_table_metadata atm
        JOIN #VisualIds v ON atm.visualId = v.visualId
        WHERE atm.tableName IS NOT NULL

        UNION

        SELECT DISTINCT dim.tableName
        FROM data_input_table_metadata dim
        JOIN #VisualIds v ON dim.visualId = v.visualId
        WHERE dim.tableName IS NOT NULL;

        /* ---------------------------------------
           DROP dynamic visual-specific tables FIRST
        ---------------------------------------- */
        DECLARE @tableName SYSNAME;
        DECLARE @columnName SYSNAME;
        DECLARE @sql NVARCHAR(MAX);

        /* Drop dynamic tables */
        DECLARE drop_cur CURSOR FAST_FORWARD FOR
            SELECT tableName FROM #DynamicTables;

        OPEN drop_cur;
        FETCH NEXT FROM drop_cur INTO @tableName;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF OBJECT_ID(QUOTENAME(@SCHEMA) + '.' + QUOTENAME(@tableName), 'U') IS NOT NULL
            BEGIN
                SET @sql = N'DROP TABLE ' 
                         + QUOTENAME(@SCHEMA) + '.' + QUOTENAME(@tableName);

                EXEC sp_executesql @sql;
            END;

            FETCH NEXT FROM drop_cur INTO @tableName;
        END;

        CLOSE drop_cur;
        DEALLOCATE drop_cur;

        /* ---------------------------------------
           Delete rows from configured tables
        ---------------------------------------- */
        DECLARE cur CURSOR FAST_FORWARD FOR
            SELECT
                JSON_VALUE(value, '$.table'),
                JSON_VALUE(value, '$.column')
            FROM OPENJSON(@VisualDeleteConfig, '$.tables')
            ORDER BY TRY_CAST([key] AS INT);

        OPEN cur;
        FETCH NEXT FROM cur INTO @tableName, @columnName;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF OBJECT_ID(QUOTENAME(@SCHEMA) + '.' + QUOTENAME(@tableName), 'U') IS NOT NULL
            BEGIN
                SET @sql = N'
                    DELETE t
                    FROM ' + QUOTENAME(@SCHEMA) + '.' + QUOTENAME(@tableName) + ' t
                    JOIN #VisualIds v
                      ON t.' + QUOTENAME(@columnName) + ' = v.visualId';

                EXEC sp_executesql @sql;
            END;

            FETCH NEXT FROM cur INTO @tableName, @columnName;
        END;

        CLOSE cur;
        DEALLOCATE cur;

        /* ---------------------------------------
           Cleanup metadata tables
        ---------------------------------------- */
        DELETE atm
        FROM audit_table_metadata atm
        JOIN #VisualIds v ON atm.visualId = v.visualId;

        DELETE dim
        FROM data_input_table_metadata dim
        JOIN #VisualIds v ON dim.visualId = v.visualId;

        /* ---------------------------------------
           Delete visuals
        ---------------------------------------- */
        DELETE v
        FROM visual v
        JOIN #VisualIds ids ON v.id = ids.visualId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;

GO

