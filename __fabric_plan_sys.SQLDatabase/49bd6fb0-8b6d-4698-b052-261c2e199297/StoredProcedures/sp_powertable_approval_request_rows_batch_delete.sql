
              CREATE PROCEDURE [49bd6fb0-8b6d-4698-b052-261c2e199297].[sp_powertable_approval_request_rows_batch_delete] 
              @InputData as nvarchar(max),
              @approvalRequestId as INT
          AS 
          BEGIN
              SET NOCOUNT ON;
              DECLARE @sql NVARCHAR(MAX) = '';
              DECLARE @currentTimeString NVARCHAR(50) = CONVERT(NVARCHAR(50), SYSDATETIME(), 121);
              DECLARE @TempTableName NVARCHAR(128) = '#WRR_DEL_TEMP' + REPLACE(REPLACE(REPLACE(REPLACE(@currentTimeString, '-', ''), ':', ''),' ',''),'.','');
          
              -- Create a temporary table to hold the JSON data
              SET @sql = N'
                  CREATE TABLE ' + QUOTENAME(@TempTableName) + N' (
                      rowMeta nvarchar(max) NOT NULL
                  );
              ';
              
              -- Insert the incoming values into the temporary table
              SET @sql = @sql + N'
                  INSERT INTO ' + QUOTENAME(@TempTableName) + N'
                  SELECT value as rowMeta FROM OPENJSON(@InputData);
              ';
          
          
              SET @sql = @sql + 'UPDATE [49bd6fb0-8b6d-4698-b052-261c2e199297].powertable_approval_request_rows SET status = 500 FROM [49bd6fb0-8b6d-4698-b052-261c2e199297].powertable_approval_request_rows inner join ' + @TempTableName + ' as temp on temp.rowMeta = powertable_approval_request_rows.rowMeta where powertable_approval_request_rows.approvalRequestId = @approvalRequestId;';
              
              SET @sql = @sql + N'DROP TABLE ' + @TempTableName + ';';
          
              EXEC sp_executesql @sql, N'@InputData NVARCHAR(MAX), @approvalRequestId INT', @InputData, @approvalRequestId;
              SET NOCOUNT OFF;
          END

GO

