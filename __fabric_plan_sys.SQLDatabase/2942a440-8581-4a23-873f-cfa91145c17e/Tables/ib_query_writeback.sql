CREATE TABLE [2942a440-8581-4a23-873f-cfa91145c17e].[ib_query_writeback] (
    [id]              INT            IDENTITY (1, 1) NOT NULL,
    [queryId]         INT            NOT NULL,
    [executionId]     VARCHAR (2048) NULL,
    [type]            INT            NOT NULL,
    [errorCode]       NVARCHAR (MAX) NULL,
    [startTime]       INT            NULL,
    [endTime]         INT            NULL,
    [writebackMeta]   NVARCHAR (MAX) NOT NULL,
    [destinationMeta] NVARCHAR (MAX) NULL,
    [status]          INT            CONSTRAINT [DF_129b26f7b9fd5041abfb3cac11f] DEFAULT ((10)) NOT NULL,
    [createdBy]       NVARCHAR (128) NOT NULL,
    [updatedBy]       NVARCHAR (128) NOT NULL,
    [createdAt]       INT            NOT NULL,
    [updatedAt]       INT            NOT NULL,
    CONSTRAINT [PK_439ddb055cfa514c168316cbff4] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_bf27e2b1a7d524cbb8c5475aba7] FOREIGN KEY ([queryId]) REFERENCES [2942a440-8581-4a23-873f-cfa91145c17e].[ib_queries] ([id]) ON DELETE CASCADE
);


GO

CREATE NONCLUSTERED INDEX [idx_ib_query_writeback_queryId]
    ON [2942a440-8581-4a23-873f-cfa91145c17e].[ib_query_writeback]([queryId] ASC);


GO

CREATE NONCLUSTERED INDEX [idx_ib_query_writeback_queryId_status]
    ON [2942a440-8581-4a23-873f-cfa91145c17e].[ib_query_writeback]([queryId] ASC, [status] ASC);


GO

CREATE NONCLUSTERED INDEX [idx_ib_query_writeback_status]
    ON [2942a440-8581-4a23-873f-cfa91145c17e].[ib_query_writeback]([status] ASC);


GO

