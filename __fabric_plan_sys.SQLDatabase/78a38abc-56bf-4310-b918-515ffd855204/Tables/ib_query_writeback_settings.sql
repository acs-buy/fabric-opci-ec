CREATE TABLE [78a38abc-56bf-4310-b918-515ffd855204].[ib_query_writeback_settings] (
    [id]            INT              IDENTITY (1, 1) NOT NULL,
    [queryId]       INT              NOT NULL,
    [writebackMeta] NVARCHAR (MAX)   NOT NULL,
    [status]        INT              CONSTRAINT [DF_71ad49263e7d748f7bfad6ec96d] DEFAULT ((10)) NOT NULL,
    [createdBy]     NVARCHAR (128)   NOT NULL,
    [updatedBy]     NVARCHAR (128)   NOT NULL,
    [createdAt]     INT              NOT NULL,
    [updatedAt]     INT              NOT NULL,
    [recordGuid]    UNIQUEIDENTIFIER CONSTRAINT [DF_ib_query_writeback_settings_recordGuid] DEFAULT (newsequentialid()) NOT NULL,
    CONSTRAINT [PK_ccab368b737d646370b5c0b7e71] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_8bcb8471b229716279935805b96] FOREIGN KEY ([queryId]) REFERENCES [78a38abc-56bf-4310-b918-515ffd855204].[ib_queries] ([id]) ON DELETE CASCADE
);


GO

CREATE NONCLUSTERED INDEX [idx_ib_query_writeback_settings_queryId]
    ON [78a38abc-56bf-4310-b918-515ffd855204].[ib_query_writeback_settings]([queryId] ASC);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_ib_query_writeback_settings_recordGuid]
    ON [78a38abc-56bf-4310-b918-515ffd855204].[ib_query_writeback_settings]([recordGuid] ASC);


GO

