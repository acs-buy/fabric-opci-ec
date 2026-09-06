CREATE TABLE [a17b18e9-b7f7-4bd9-b911-cf436bc66b7a].[audit_table_metadata] (
    [id]            INT            IDENTITY (1, 1) NOT NULL,
    [tableName]     NVARCHAR (450) NOT NULL,
    [visualId]      INT            NOT NULL,
    [dimensionHash] NVARCHAR (450) NOT NULL,
    [status]        INT            CONSTRAINT [DF_ed58cd20944539db69f1c7dec1b] DEFAULT ((10)) NOT NULL,
    [createdBy]     NVARCHAR (128) NOT NULL,
    [updatedBy]     NVARCHAR (128) NOT NULL,
    [createdAt]     INT            NOT NULL,
    [updatedAt]     INT            NOT NULL,
    CONSTRAINT [PK_d8416b4569a03e42b534b0fc25a] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_92e65ca174f48ee8c2d2276faf1] FOREIGN KEY ([visualId]) REFERENCES [a17b18e9-b7f7-4bd9-b911-cf436bc66b7a].[visual] ([id])
);


GO

CREATE NONCLUSTERED INDEX [idx_audit_table_metadata_visualId_dimensionHash]
    ON [a17b18e9-b7f7-4bd9-b911-cf436bc66b7a].[audit_table_metadata]([visualId] ASC, [dimensionHash] ASC);


GO

