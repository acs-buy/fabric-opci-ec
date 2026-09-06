
              CREATE PROCEDURE [4f48cf63-7c36-4ac3-9f09-a1d413854e4d].[sp_powertable_approval_request_rows_batch_delete] 
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
          
          
              SET @sql = @sql + 'UPDATE [4f48cf63-7c36-4ac3-9f09-a1d413854e4d].powertable_approval_request_rows SET status = 500 FROM [4f48cf63-7c36-4ac3-9f09-a1d413854e4d].powertable_approval_request_rows inner join ' + @TempTableName + ' as temp on temp.rowMeta = powertable_approval_request_rows.rowMeta where powertable_approval_request_rows.approvalRequestId = @approvalRequestId;';
              
              SET @sql = @sql + N'DROP TABLE ' + @TempTableName + ';';
          
              EXEC sp_executesql @sql, N'@InputData NVARCHAR(MAX), @approvalRequestId INT', @InputData, @approvalRequestId;
              SET NOCOUNT OFF;
          END

GO

