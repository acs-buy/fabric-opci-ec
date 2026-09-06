CREATE TABLE [88469c8b-a912-49ff-b453-4d359bdddd12].[powertable_source] (
    [id]                   INT              IDENTITY (1, 1) NOT NULL,
    [dbName]               VARCHAR (255)    NULL,
    [dbHost]               VARCHAR (255)    NULL,
    [tableName]            VARCHAR (255)    NOT NULL,
    [schemaName]           NVARCHAR (MAX)   NULL,
    [tableType]            INT              NULL,
    [meta]                 NVARCHAR (MAX)   NULL,
    [creationMode]         INT              NULL,
    [fileImportType]       INT              NULL,
    [status]               INT              CONSTRAINT [DF_2b063b5739be18a99e045032c12] DEFAULT ((10)) NOT NULL,
    [createdBy]            NVARCHAR (128)   NOT NULL,
    [updatedBy]            NVARCHAR (128)   NOT NULL,
    [createdAt]            INT              NOT NULL,
    [updatedAt]            INT              NOT NULL,
    [connectionId]         VARCHAR (255)    NULL,
    [recordGuid]           UNIQUEIDENTIFIER CONSTRAINT [DF_powertable_source_recordGuid] DEFAULT (newsequentialid()) NOT NULL,
    [connectionIdVariable] VARCHAR (256)    NULL,
    [databaseVariable]     VARCHAR (256)    NULL,
    [sqlTargetArtifact]    NVARCHAR (MAX)   NULL,
    CONSTRAINT [PK_4fb18167f2d83b6fdfb6980a9df] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_powertable_source_recordGuid]
    ON [88469c8b-a912-49ff-b453-4d359bdddd12].[powertable_source]([recordGuid] ASC);


GO

