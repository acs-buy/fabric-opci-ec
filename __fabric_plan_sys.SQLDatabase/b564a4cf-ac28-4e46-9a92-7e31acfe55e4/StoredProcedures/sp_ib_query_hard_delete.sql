
      CREATE   PROCEDURE [b564a4cf-ac28-4e46-9a92-7e31acfe55e4].[sp_ib_query_hard_delete] 
      @QueryIds AS nvarchar(max)
      AS 
      BEGIN
        SET NOCOUNT ON;

        DECLARE @TempTableName NVARCHAR(128);
        DECLARE @currentTimeString NVARCHAR(50) = CONVERT(NVARCHAR(50), SYSDATETIME(), 121);
        SET @TempTableName = '#QID_DEL_TEMP' + REPLACE(REPLACE(REPLACE(REPLACE(@currentTimeString, '-', ''), ':', ''), ' ', ''), '.', '');

        DECLARE @sql NVARCHAR(MAX) = '';
        DECLARE @DeletedJobsCount INT = 0;
        DECLARE @DeletedWritebackCount INT = 0;

        BEGIN TRY
          BEGIN TRANSACTION;

          -- Create temporary table to hold query IDs
          SET @sql = N'
            CREATE TABLE ' + QUOTENAME(@TempTableName) + N' (
              queryId INT NOT NULL
            );
          ';

          -- Insert query IDs from JSON array into temp table
          SET @sql = @sql + N'
            INSERT INTO ' + QUOTENAME(@TempTableName) + N'
            SELECT CAST(value AS INT) as queryId FROM OPENJSON(@QueryIds);
          ';

          -- Delete from ib_query_jobs
          SET @sql = @sql + N'
            DELETE qj
            FROM [b564a4cf-ac28-4e46-9a92-7e31acfe55e4].[ib_query_jobs] qj
            INNER JOIN ' + QUOTENAME(@TempTableName) + N' t ON t.queryId = qj.queryId;
            SET @DeletedJobsCount = @@ROWCOUNT;
          ';

          -- Delete from ib_query_writeback
          SET @sql = @sql + N'
            DELETE qw
            FROM [b564a4cf-ac28-4e46-9a92-7e31acfe55e4].[ib_query_writeback] qw
            INNER JOIN ' + QUOTENAME(@TempTableName) + N' t ON t.queryId = qw.queryId;
            SET @DeletedWritebackCount = @@ROWCOUNT;
          ';

          -- Drop temp table
          SET @sql = @sql + N'
            DROP TABLE ' + QUOTENAME(@TempTableName) + N';
          ';

          -- Execute the dynamic SQL
          EXEC sp_executesql @sql,
            N'@QueryIds NVARCHAR(MAX), @DeletedJobsCount INT OUTPUT, @DeletedWritebackCount INT OUTPUT',
            @QueryIds,
            @DeletedJobsCount OUTPUT,
            @DeletedWritebackCount OUTPUT;

          COMMIT TRANSACTION;

          -- Return success result
          SELECT 
            1 AS success,
            @DeletedJobsCount AS deletedJobsCount,
            @DeletedWritebackCount AS deletedWritebackCount,
            NULL AS errorMessage;

        END TRY
        BEGIN CATCH
          IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

          -- Return error result
          SELECT 
            0 AS success,
            0 AS deletedJobsCount,
            0 AS deletedWritebackCount,
            ERROR_MESSAGE() AS errorMessage;
        END CATCH

        SET NOCOUNT OFF;
      END

GO

