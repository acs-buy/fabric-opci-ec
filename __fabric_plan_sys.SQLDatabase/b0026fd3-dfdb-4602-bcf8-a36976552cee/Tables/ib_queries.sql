CREATE TABLE [b0026fd3-dfdb-4602-bcf8-a36976552cee].[ib_queries] (
    [id]             INT            IDENTITY (1, 1) NOT NULL,
    [name]           VARCHAR (2048) NULL,
    [workloadItemId] NVARCHAR (36)  NOT NULL,
    [visualId]       INT            NULL,
    [filePath]       VARCHAR (1024) NULL,
    [type]           INT            NOT NULL,
    [sourceId]       INT            NULL,
    [queryGroupId]   INT            NULL,
    [queryGUID]      VARCHAR (255)  NOT NULL,
    [meta]           NVARCHAR (MAX) NULL,
    [status]         INT            CONSTRAINT [DF_b8e376a04b0a1758a37d8af0195] DEFAULT ((10)) NOT NULL,
    [createdBy]      NVARCHAR (128) NOT NULL,
    [updatedBy]      NVARCHAR (128) NOT NULL,
    [createdAt]      INT            NOT NULL,
    [updatedAt]      INT            NOT NULL,
    CONSTRAINT [PK_d91b4ca7175bb84e6531e06efed] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_1ec64af6f1377b1b6e048da4c4d] FOREIGN KEY ([sourceId]) REFERENCES [b0026fd3-dfdb-4602-bcf8-a36976552cee].[ib_source] ([id]) ON DELETE CASCADE,
    CONSTRAINT [FK_a9eca4e52539c253c8e166eaa54] FOREIGN KEY ([visualId]) REFERENCES [b0026fd3-dfdb-4602-bcf8-a36976552cee].[visual] ([id])
);


GO

CREATE NONCLUSTERED INDEX [idx_ib_queries_queryGroupId]
    ON [b0026fd3-dfdb-4602-bcf8-a36976552cee].[ib_queries]([queryGroupId] ASC);


GO

CREATE NONCLUSTERED INDEX [idx_ib_queries_queryGUID]
    ON [b0026fd3-dfdb-4602-bcf8-a36976552cee].[ib_queries]([queryGUID] ASC);


GO

CREATE NONCLUSTERED INDEX [idx_ib_queries_visualId_sourceId]
    ON [b0026fd3-dfdb-4602-bcf8-a36976552cee].[ib_queries]([visualId] ASC, [sourceId] ASC);


GO

CREATE NONCLUSTERED INDEX [idx_ib_queries_workloadItemId]
    ON [b0026fd3-dfdb-4602-bcf8-a36976552cee].[ib_queries]([workloadItemId] ASC);


GO

CREATE NONCLUSTERED INDEX [idx_ib_queries_workloadItemId_status]
    ON [b0026fd3-dfdb-4602-bcf8-a36976552cee].[ib_queries]([workloadItemId] ASC, [status] ASC);


GO

