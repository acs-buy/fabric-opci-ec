CREATE TABLE [5df03107-c058-4934-9696-943dffe44c90].[ib_append_query_mapping] (
    [id]         INT              IDENTITY (1, 1) NOT NULL,
    [visualId]   INT              NULL,
    [sourceId]   INT              NOT NULL,
    [queryId]    INT              NOT NULL,
    [status]     INT              CONSTRAINT [DF_4b6f8c42c6efac74c8debc0e228] DEFAULT ((10)) NOT NULL,
    [createdBy]  NVARCHAR (128)   NOT NULL,
    [updatedBy]  NVARCHAR (128)   NOT NULL,
    [createdAt]  INT              NOT NULL,
    [updatedAt]  INT              NOT NULL,
    [recordGuid] UNIQUEIDENTIFIER CONSTRAINT [DF_ib_append_query_mapping_recordGuid] DEFAULT (newsequentialid()) NOT NULL,
    CONSTRAINT [PK_ce7288f7103c5778d994ef7b20f] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_655d4a8fb9e97599fb861b81cfe] FOREIGN KEY ([visualId]) REFERENCES [5df03107-c058-4934-9696-943dffe44c90].[visual] ([id]),
    CONSTRAINT [FK_70d1e897c99ace717e9b2014f74] FOREIGN KEY ([sourceId]) REFERENCES [5df03107-c058-4934-9696-943dffe44c90].[ib_source] ([id]),
    CONSTRAINT [FK_74dd35ddb1b4fbd8f776c789957] FOREIGN KEY ([queryId]) REFERENCES [5df03107-c058-4934-9696-943dffe44c90].[ib_queries] ([id]) ON DELETE CASCADE
);


GO

CREATE NONCLUSTERED INDEX [idx_ib_append_query_mapping_queryId]
    ON [5df03107-c058-4934-9696-943dffe44c90].[ib_append_query_mapping]([queryId] ASC);


GO

CREATE NONCLUSTERED INDEX [idx_ib_append_query_mapping_sourceId]
    ON [5df03107-c058-4934-9696-943dffe44c90].[ib_append_query_mapping]([sourceId] ASC);


GO

CREATE NONCLUSTERED INDEX [idx_ib_append_query_mapping_visualId_sourceId_queryId]
    ON [5df03107-c058-4934-9696-943dffe44c90].[ib_append_query_mapping]([visualId] ASC, [sourceId] ASC, [queryId] ASC);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_ib_append_query_mapping_recordGuid]
    ON [5df03107-c058-4934-9696-943dffe44c90].[ib_append_query_mapping]([recordGuid] ASC);


GO

