
                  CREATE PROCEDURE [2b06b4a7-d5c3-4748-89a6-31d60790423e].[sp_powertable_approval_request_rows_batch_read] 
                  @approvalRequestId as INT,
                  @InputData as nvarchar(max),
                  @columns as nvarchar(max),
                  @status as nvarchar(max),
                  @syncStatus as nvarchar(max)
              AS 
              BEGIN
                  DECLARE @sql NVARCHAR(MAX) = '';
                  DECLARE @statusCondition NVARCHAR(MAX) = '';
                  DECLARE @innerJoinCondition NVARCHAR(MAX) = '';
                  DECLARE @currentTimeString NVARCHAR(50) = CONVERT(NVARCHAR(50), SYSDATETIME(), 121);
                  DECLARE @TempTableName NVARCHAR(128) = '#WRR_READ_TEMP' + REPLACE(REPLACE(REPLACE(REPLACE(@currentTimeString, '-', ''), ':', ''),' ',''),'.','');

                  if (@InputData != '')
                  BEGIN
                  -- Create a temporary table to hold the JSON data
                  SET @sql = N'
                  CREATE TABLE ' + QUOTENAME(@TempTableName) + N' (
                      rowMeta nvarchar(max) NOT NULL
                  );';
                  
                  -- Insert the incoming values into the temporary table
                  SET @sql = @sql + N'
                  INSERT INTO ' + QUOTENAME(@TempTableName) + N'
                  SELECT value as rowMeta FROM OPENJSON(@InputData);
                  ';

                  SET @innerJoinCondition = ' inner join ' + @TempTableName + ' as temp on temp.rowMeta = powertable_approval_request_rows.rowMeta';
                  END

                  if (@status != '')
                  BEGIN
                  SET @statusCondition = ' AND powertable_approval_request_rows.status IN (' + @status + ')';
                  END

                  if (@syncStatus != '')
                  BEGIN
                  SET @statusCondition = ' AND powertable_approval_request_rows.syncStatus IN (' + @syncStatus + ')';
                  END

                  if (@columns = '')
                  BEGIN
                   SET @sql = @sql + N'SELECT count(*) as count FROM [2b06b4a7-d5c3-4748-89a6-31d60790423e].powertable_approval_request_rows' + @innerJoinCondition + ' where powertable_approval_request_rows.approvalRequestId = @approvalRequestId' + @statusCondition + ';';
                  END
                  ELSE
                  BEGIN
                  SET @sql = @sql + N'SELECT '+ @columns + ' FROM [2b06b4a7-d5c3-4748-89a6-31d60790423e].powertable_approval_request_rows' + @innerJoinCondition + ' where powertable_approval_request_rows.approvalRequestId = @approvalRequestId' + @statusCondition + ';';
                  END
              
                  if (@InputData != '')
                  BEGIN
                  SET @sql = @sql + N'DROP TABLE ' + @TempTableName + ';';
                  END

                  EXEC sp_executesql @sql, N'@InputData NVARCHAR(MAX), @approvalRequestId INT', @InputData, @approvalRequestId;
                  RETURN;
              END

GO

