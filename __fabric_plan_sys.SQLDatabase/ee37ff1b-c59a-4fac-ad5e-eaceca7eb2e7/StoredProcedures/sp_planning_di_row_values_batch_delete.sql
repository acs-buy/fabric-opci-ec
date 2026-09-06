
        CREATE PROCEDURE [ee37ff1b-c59a-4fac-ad5e-eaceca7eb2e7].[sp_planning_di_row_values_batch_delete] 
        @InputData AS nvarchar(max),
        @DataInputRowIds AS nvarchar(max),
        @DIVTableName AS SYSNAME
        AS 
        BEGIN
        SET NOCOUNT ON;
          DECLARE @sql NVARCHAR(MAX) = '';
          DECLARE @currentTimeString NVARCHAR(50) = CONVERT(NVARCHAR(50), SYSDATETIME(), 121);
          DECLARE @TempTableName NVARCHAR(128) = '#CRV_DEL_TEMP' + REPLACE(REPLACE(REPLACE(REPLACE(@currentTimeString, '-', ''), ':', ''),' ',''),'.','');
          DECLARE @DataInputRowTempTableName NVARCHAR(128) = '#CR_DEL_TEMP' + REPLACE(REPLACE(REPLACE(REPLACE(@currentTimeString, '-', ''), ':', ''),' ',''),'.','');

          -- Create a temporary table to hold the JSON data
          SET @sql = N'
              CREATE TABLE ' + QUOTENAME(@TempTableName) + N' (
                  rowId varchar(2048) NOT NULL
              );
          ';
          
          -- Insert the incoming values into the temporary table
          SET @sql = @sql + N'
              INSERT INTO [ee37ff1b-c59a-4fac-ad5e-eaceca7eb2e7].' + QUOTENAME(@TempTableName) + N'
              SELECT value as rowId FROM OPENJSON(@InputData);
          ';
      
          SET @sql = @sql + '
            DELETE [ee37ff1b-c59a-4fac-ad5e-eaceca7eb2e7].' + QUOTENAME(@DIVTableName) + '
            FROM [ee37ff1b-c59a-4fac-ad5e-eaceca7eb2e7].' + QUOTENAME(@DIVTableName) + '
            INNER JOIN [ee37ff1b-c59a-4fac-ad5e-eaceca7eb2e7].' + QUOTENAME(@TempTableName) + ' AS temp ON temp.rowId = [ee37ff1b-c59a-4fac-ad5e-eaceca7eb2e7].' + QUOTENAME(@DIVTableName) + '.rowId;';

          SET @sql = @sql + N'DROP TABLE [ee37ff1b-c59a-4fac-ad5e-eaceca7eb2e7].' + @TempTableName + ';';

          -- Create a temporary table to hold the JSON data
          SET @sql = @sql + N'
            IF LEN(@DataInputRowIds) > 0
            BEGIN
            -- Create a temporary table to hold the JSON data
            CREATE TABLE ' + QUOTENAME(@DataInputRowTempTableName) + N' (
                rowId varchar(255) NOT NULL
            );

            -- Insert the incoming values into the temporary table
            INSERT INTO [ee37ff1b-c59a-4fac-ad5e-eaceca7eb2e7].' + QUOTENAME(@DataInputRowTempTableName) + N'
            SELECT value as rowId FROM OPENJSON(@DataInputRowIds);

            UPDATE [ee37ff1b-c59a-4fac-ad5e-eaceca7eb2e7].data_input_row SET status = 500 FROM [ee37ff1b-c59a-4fac-ad5e-eaceca7eb2e7].data_input_row inner join [ee37ff1b-c59a-4fac-ad5e-eaceca7eb2e7].' + @DataInputRowTempTableName + ' as temp on temp.rowId = data_input_row.id;

            DROP TABLE ' + @DataInputRowTempTableName + ';
            END
          ';

          -- Execute the dynamic SQL with the parameters passed correctly
          EXEC sp_executesql @sql, 
            N'@InputData NVARCHAR(MAX), @DataInputRowIds NVARCHAR(MAX)', 
            @InputData, 
            @DataInputRowIds;

          SET NOCOUNT OFF;
        END

GO

