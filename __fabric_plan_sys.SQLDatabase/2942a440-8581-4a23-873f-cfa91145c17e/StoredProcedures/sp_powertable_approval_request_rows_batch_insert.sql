
                CREATE PROCEDURE [2942a440-8581-4a23-873f-cfa91145c17e].[sp_powertable_approval_request_rows_batch_insert] 
    @InputData          AS NVARCHAR(MAX),
    @approvalRequestId  AS INT,
    @createdBy          AS NVARCHAR(128),
    @updatedBy          AS NVARCHAR(128),
    @createdAt          AS INT,
    @updatedAt          AS INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @sql               NVARCHAR(MAX) = '';
    DECLARE @currentTimeString NVARCHAR(50)  = CONVERT(NVARCHAR(50), SYSDATETIME(), 121);
    DECLARE @TempTableName     NVARCHAR(128) = '#WRR_INSERT_TEMP' + REPLACE(REPLACE(REPLACE(REPLACE(@currentTimeString, '-', ''), ':', ''), ' ', ''), '.', '');

    SET @sql = N'
        CREATE TABLE ' + QUOTENAME(@TempTableName) + N' (
            rowId             NVARCHAR(MAX),
            rowMeta           NVARCHAR(MAX),
            approvalRequestId INT,
            createdBy         NVARCHAR(128),
            updatedBy         NVARCHAR(128),
            createdAt         INT,
            updatedAt         INT
        );
    ';

    SET @sql = @sql + N'
        INSERT INTO ' + QUOTENAME(@TempTableName) + N'
            (rowId, rowMeta, approvalRequestId, createdBy, updatedBy, createdAt, updatedAt)
        SELECT
            rowId, rowMeta,
            @approvalRequestId, @createdBy, @updatedBy, @createdAt, @updatedAt
        FROM OPENJSON(@InputData)
        WITH (
            rowId    NVARCHAR(MAX) ''$.ri'',
            rowMeta  NVARCHAR(MAX) ''$.rei''
        );
    ';

    SET @sql = @sql + N'
        INSERT INTO [2942a440-8581-4a23-873f-cfa91145c17e].powertable_approval_request_rows
            (rowId, rowMeta, approvalRequestId, createdBy, updatedBy, createdAt, updatedAt)
        SELECT
            temp.rowId, temp.rowMeta, temp.approvalRequestId,
            temp.createdBy, temp.updatedBy, temp.createdAt, temp.updatedAt
        FROM ' + QUOTENAME(@TempTableName) + N' AS temp;
    ';

    SET @sql = @sql + N' DROP TABLE ' + QUOTENAME(@TempTableName) + N';';

    EXEC sp_executesql @sql,
        N'@InputData NVARCHAR(MAX), @approvalRequestId INT, @createdBy NVARCHAR(128),
          @updatedBy NVARCHAR(128), @createdAt INT, @updatedAt INT',
        @InputData, @approvalRequestId, @createdBy, @updatedBy, @createdAt, @updatedAt;

    SET NOCOUNT OFF;
END

GO

