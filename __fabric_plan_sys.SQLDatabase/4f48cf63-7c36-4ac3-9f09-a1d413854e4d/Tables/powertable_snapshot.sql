CREATE TABLE [4f48cf63-7c36-4ac3-9f09-a1d413854e4d].[powertable_snapshot] (
    [id]               INT            IDENTITY (1, 1) NOT NULL,
    [name]             NVARCHAR (MAX) NULL,
    [description]      NVARCHAR (MAX) NULL,
    [layoutType]       VARCHAR (255)  NULL,
    [sourceId]         INT            NOT NULL,
    [storageType]      INT            NOT NULL,
    [fileFormat]       VARCHAR (20)   NOT NULL,
    [fileName]         NVARCHAR (MAX) NULL,
    [totalRows]        INT            NULL,
    [filters]          NVARCHAR (MAX) NULL,
    [schemaData]       NVARCHAR (MAX) NULL,
    [columnConfigData] NVARCHAR (MAX) NOT NULL,
    [isCurrent]        INT            NULL,
    [status]           INT            NOT NULL,
    [createdAt]        INT            NOT NULL,
    [updatedAt]        INT            NOT NULL,
    [createdBy]        NVARCHAR (128) NOT NULL,
    [updatedBy]        NVARCHAR (128) NOT NULL,
    CONSTRAINT [PK_7e40724730dc83643b1ee9f4c5c] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_snapshot_sourceIdSnapshot] FOREIGN KEY ([sourceId]) REFERENCES [4f48cf63-7c36-4ac3-9f09-a1d413854e4d].[powertable_source] ([id])
);


GO

