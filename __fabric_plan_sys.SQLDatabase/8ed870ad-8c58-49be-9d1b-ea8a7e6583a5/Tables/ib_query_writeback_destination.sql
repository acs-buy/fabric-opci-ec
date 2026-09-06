CREATE TABLE [8ed870ad-8c58-49be-9d1b-ea8a7e6583a5].[ib_query_writeback_destination] (
    [id]                   INT              IDENTITY (1, 1) NOT NULL,
    [queryId]              INT              NOT NULL,
    [connectionId]         VARCHAR (255)    CONSTRAINT [DF_912e32fa42ce402d03425080472] DEFAULT ('') NULL,
    [tableName]            VARCHAR (255)    NOT NULL,
    [settings]             VARCHAR (MAX)    NOT NULL,
    [settingsHash]         VARCHAR (255)    NULL,
    [status]               INT              CONSTRAINT [DF_8e1d9f6a0f12840702bfd80af7a] DEFAULT ((10)) NOT NULL,
    [createdBy]            NVARCHAR (128)   NOT NULL,
    [updatedBy]            NVARCHAR (128)   NOT NULL,
    [createdAt]            INT              NOT NULL,
    [updatedAt]            INT              NOT NULL,
    [recordGuid]           UNIQUEIDENTIFIER CONSTRAINT [DF_ib_query_writeback_destination_recordGuid] DEFAULT (newsequentialid()) NOT NULL,
    [connectionIdVariable] VARCHAR (256)    NULL,
    CONSTRAINT [PK_f72adf9413b4d2d62fa634c8ca7] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_7534fdf394126d74de811d59cd7] FOREIGN KEY ([queryId]) REFERENCES [8ed870ad-8c58-49be-9d1b-ea8a7e6583a5].[ib_queries] ([id]) ON DELETE CASCADE
);


GO

CREATE NONCLUSTERED INDEX [idx_ib_query_writeback_destination_queryId]
    ON [8ed870ad-8c58-49be-9d1b-ea8a7e6583a5].[ib_query_writeback_destination]([queryId] ASC);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_ib_query_writeback_destination_recordGuid]
    ON [8ed870ad-8c58-49be-9d1b-ea8a7e6583a5].[ib_query_writeback_destination]([recordGuid] ASC);


GO

