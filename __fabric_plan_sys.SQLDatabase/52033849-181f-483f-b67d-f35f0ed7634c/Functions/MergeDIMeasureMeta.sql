
        CREATE   FUNCTION [52033849-181f-483f-b67d-f35f0ed7634c].[MergeDIMeasureMeta]
        (
          @existingMeta NVARCHAR(MAX),
          @incomingMeta  NVARCHAR(MAX),
          @updatedAt BIGINT,
          @updatedBy NVARCHAR(128),
          @updatedByUPN NVARCHAR(320)
        )
        RETURNS NVARCHAR(MAX)
        AS
        BEGIN
          SET @existingMeta = ISNULL(@existingMeta, '{}');
          SET @incomingMeta = ISNULL(@incomingMeta, '{}');

          DECLARE @merged NVARCHAR(MAX) = @incomingMeta;

          -- Carry over createdAt and createdBy from existingMeta
          DECLARE @createdAt BIGINT = TRY_CAST(JSON_VALUE(@existingMeta, '$.createdAt') AS BIGINT);
          DECLARE @createdBy NVARCHAR(128) = TRY_CAST(JSON_VALUE(@existingMeta, '$.createdBy') AS NVARCHAR(128));

          IF @createdAt IS NOT NULL
            SET @merged = JSON_MODIFY(@merged, '$.createdAt', @createdAt);
          IF @createdBy IS NOT NULL
            SET @merged = JSON_MODIFY(@merged, '$.createdBy', @createdBy);

          -- Inject fixed fields
          SET @merged = JSON_MODIFY(@merged, '$.updatedAt', @updatedAt);
          SET @merged = JSON_MODIFY(@merged, '$.updatedBy', @updatedBy);
          SET @merged = JSON_MODIFY(@merged, '$.updatedByUPN', @updatedByUPN);

          RETURN @merged;
        END;

GO

