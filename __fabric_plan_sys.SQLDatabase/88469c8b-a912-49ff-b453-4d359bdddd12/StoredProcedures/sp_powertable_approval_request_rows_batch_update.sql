
                          CREATE PROCEDURE [88469c8b-a912-49ff-b453-4d359bdddd12].[sp_powertable_approval_request_rows_batch_update] 
                          @InputData as nvarchar(max),
                          @approvalRequestId as INT,
                          @updateColumn as varchar(255),
                          @updateValue as varchar(255),
                          @updatedBy as nvarchar(128),
                          @updatedAt as INT
                      AS 
                      BEGIN
                      
                          SET NOCOUNT ON;
                          DECLARE @sql NVARCHAR(MAX) = '';
                          DECLARE @currentTimeString NVARCHAR(50) = CONVERT(NVARCHAR(50), SYSDATETIME(), 121);
                          DECLARE @TempTableName NVARCHAR(128) = '#WRR_UPDATE_TEMP' + REPLACE(REPLACE(REPLACE(REPLACE(@currentTimeString, '-', ''), ':', ''),' ',''),'.','');
                      
                          -- Create a temporary table to hold the JSON data
                          SET @sql = N'
                              CREATE TABLE ' + QUOTENAME(@TempTableName) + N' (
                                  rowMeta NVARCHAR(MAX) NOT NULL
                              );
                          ';
      
                          -- Insert incoming JSON data into temp table
                          SET @sql = @sql + N'
                              INSERT INTO ' + QUOTENAME(@TempTableName) + N'
                              (rowMeta)
                              SELECT * FROM OPENJSON(@InputData)
                              WITH (
                                  "rowMeta" nvarchar(max) ''$.rei''
                              );
                          ';
      
                          -- Update the values
                          SET @sql = @sql + 'UPDATE [88469c8b-a912-49ff-b453-4d359bdddd12].powertable_approval_request_rows 
                          SET 
                              ' + @updateColumn + ' = ' + @updateValue + ',
                              updatedBy = @updatedBy,
                              updatedAt = @updatedAt
                          FROM [88469c8b-a912-49ff-b453-4d359bdddd12].powertable_approval_request_rows
                          INNER JOIN ' +  @TempTableName + ' as temp on temp.rowMeta = powertable_approval_request_rows.rowMeta AND powertable_approval_request_rows.approvalRequestId = @approvalRequestId;';
                          
                          -- Drop the temp table
                          SET @sql = @sql + N'DROP TABLE ' + @TempTableName + ';';
      
                          EXEC sp_executesql @sql, N'@InputData NVARCHAR(MAX), @approvalRequestId as INT, @updatedBy as nvarchar(128),@updatedAt as INT', @InputData, @approvalRequestId, @updatedBy, @updatedAt;
                          SET NOCOUNT OFF;
                      END

GO

