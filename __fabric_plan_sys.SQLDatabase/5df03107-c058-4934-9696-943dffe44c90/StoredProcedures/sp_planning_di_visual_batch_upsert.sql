
        CREATE   PROCEDURE [5df03107-c058-4934-9696-943dffe44c90].[sp_planning_di_visual_batch_upsert]
          @Records NVARCHAR(MAX),
          @DIVTableName SYSNAME,
          @DimensionAndMeasureColumns NVARCHAR(MAX), -- JSON: [{"name": "columnName", "type": "SQL_TYPE", "jsonPath": "$.fieldName"}, ...]
          @ColumnsToUpdate NVARCHAR(MAX),      -- JSON: [{"name": "measureName", "isMetaColumn": false}, {"name": "measureMetaName", "isMetaColumn": true}]
          @UpdatedAt BIGINT,
          @updatedBy NVARCHAR(128),
          @updatedByUPN NVARCHAR(320),
          @ReturnAffectedRecords BIT = 0
        AS
        BEGIN
          SET NOCOUNT ON;

          -- Parse the dynamic columns JSON into a table
          DECLARE @ColumnTable TABLE (
            colName NVARCHAR(128),
            colType NVARCHAR(100),
            jsonPath NVARCHAR(100)
          );

          INSERT INTO @ColumnTable (colName, colType, jsonPath)
          SELECT 
            JSON_VALUE(value, '$.name'),
            JSON_VALUE(value, '$.type'),
            JSON_VALUE(value, '$.jsonPath')
          FROM OPENJSON(@DimensionAndMeasureColumns);

          -- Build dynamic SQL fragments
          DECLARE 
            @WithClause NVARCHAR(MAX) = '',
            @StagingTableColumns NVARCHAR(MAX) = '',
            @InsertColumns NVARCHAR(MAX) = '',
            @SelectColumns NVARCHAR(MAX) = '',
            @UpdateSetClause NVARCHAR(MAX) = '',
            @OutputClause NVARCHAR(MAX) = '',
            @InsertValues NVARCHAR(MAX);

          -- Add fixed columns to the fragments
          SET @WithClause    = '
            [rowId] NVARCHAR(255) ''$.ri'',
            [colId] NVARCHAR(255) ''$.ci'',
            [scenarioId] BIGINT ''$.si'',
            [filterContextHash] NVARCHAR(255) ''$.fch''';

          SET @StagingTableColumns   = '
            [rowId] NVARCHAR(255),
            [colId] NVARCHAR(255),
            [scenarioId] BIGINT,
            [filterContextHash] NVARCHAR(255)';

          SET @InsertColumns = '[rowId], [colId], [scenarioId], [filterContextHash]';
          SET @SelectColumns = '[rowId], [colId], [scenarioId], [filterContextHash]';
          SET @InsertValues = 'stg.[rowId], stg.[colId], stg.[scenarioId], stg.[filterContextHash]';

          -- Add dynamic columns to the fragments
          SELECT
            @WithClause    += ',' + QUOTENAME(colName) + ' ' + colType + ' ' + QUOTENAME(jsonPath, ''''),
            @StagingTableColumns   += ',' + QUOTENAME(colName) + ' ' + colType,
            @InsertColumns += ',' + QUOTENAME(colName),
            @InsertValues += ',stg.' + QUOTENAME(colName),
            @SelectColumns += ',' + QUOTENAME(colName)
          FROM @ColumnTable;

          -- Build update set clause from @ColumnsToUpdate
          SELECT @UpdateSetClause = STRING_AGG(
            CASE 
              WHEN JSON_VALUE(value, '$.isMetaColumn') = 'true' THEN
                QUOTENAME(JSON_VALUE(value, '$.name')) + ' = [5df03107-c058-4934-9696-943dffe44c90].[MergeDIMeasureMeta](div.' + QUOTENAME(JSON_VALUE(value, '$.name')) + ', stg.' + QUOTENAME(JSON_VALUE(value, '$.name')) + ', @UpdatedAt, @UpdatedBy, @UpdatedByUPN)'
              ELSE
                QUOTENAME(JSON_VALUE(value, '$.name')) + ' = stg.' + QUOTENAME(JSON_VALUE(value, '$.name'))
            END,
            ', '
          )
          FROM OPENJSON(@ColumnsToUpdate);

          -- Add meta columns to the insert clause and update clause
          IF @UpdateSetClause IS NOT NULL
              SET @UpdateSetClause += ', [updatedAt] = @UpdatedAt, [updatedBy] = @UpdatedBy';
          ELSE
              SET @UpdateSetClause = '[updatedAt] = @UpdatedAt, [updatedBy] = @UpdatedBy';

          SET @InsertColumns += ', [updatedAt], [updatedBy]';
          SET @InsertValues += ', @UpdatedAt, @UpdatedBy';

          IF (@ReturnAffectedRecords = 1)
          BEGIN
            SET @OutputClause = 'OUTPUT inserted.id INTO #AffectedIds';
          END

          DECLARE @sql NVARCHAR(MAX) = N'
            -- Create staging table to hold input data
            CREATE TABLE #Staging (' + @StagingTableColumns + ');

            -- Insert parsed data from JSON into staging table
            INSERT INTO #Staging
            SELECT ' + @SelectColumns + '
            FROM OPENJSON(@Records)
            WITH (' + @WithClause + ');

            -- Create temp table to capture affected rows IDs
            IF (@ReturnAffectedRecords = 1)
            BEGIN
              CREATE TABLE #AffectedIds (id BIGINT);
            END

            -- Insert into DIV table and capture the inserted rows
            MERGE INTO [5df03107-c058-4934-9696-943dffe44c90].' + QUOTENAME(@DIVTableName) + ' AS div
            USING #Staging AS stg
              ON div.rowId = stg.rowId 
                AND div.colId = stg.colId
                AND ISNULL(div.scenarioId, -1) = ISNULL(stg.scenarioId, -1)
                AND ISNULL(div.filterContextHash, '''') = ISNULL(stg.filterContextHash, '''')
            WHEN MATCHED THEN
              UPDATE SET ' + @UpdateSetClause + '
            WHEN NOT MATCHED BY TARGET THEN
              INSERT (' + @InsertColumns + ')
              VALUES (' +  @InsertValues + ')
            ' + @OutputClause + ';

            -- Return affected records if required(controlled by param)
            IF (@ReturnAffectedRecords = 1)
            BEGIN
              SELECT div.*
              FROM [5df03107-c058-4934-9696-943dffe44c90].' + QUOTENAME(@DIVTableName) + ' AS div
              INNER JOIN #AffectedIds AS temp ON temp.id = div.id;
            END
          ';

          -- Execute the dynamic SQL
          EXEC sp_executesql 
            @sql,
            N'@Records NVARCHAR(MAX), @UpdatedAt BIGINT, @updatedBy NVARCHAR(128), @updatedByUPN NVARCHAR(320), @ReturnAffectedRecords BIT',
            @Records, @UpdatedAt, @UpdatedBy, @UpdatedByUPN, @ReturnAffectedRecords;

          SET NOCOUNT OFF;
        END;

GO

