CREATE TABLE [4f48cf63-7c36-4ac3-9f09-a1d413854e4d].[powertable_column_config] (
    [id]               INT              IDENTITY (1, 1) NOT NULL,
    [columnGuid]       VARCHAR (255)    NOT NULL,
    [sourceId]         INT              NOT NULL,
    [columnName]       VARCHAR (255)    NOT NULL,
    [columnType]       INT              NOT NULL,
    [columnMeta]       NVARCHAR (MAX)   NOT NULL,
    [visualColumnType] INT              CONSTRAINT [DF_7660fb405b93442902aac6c0b64] DEFAULT ((1)) NOT NULL,
    [allowEdit]        INT              CONSTRAINT [DF_062dd031d887b3916411d9afa0e] DEFAULT ((1)) NOT NULL,
    [mandatory]        INT              CONSTRAINT [DF_a8168e050121876878b7e048527] DEFAULT ((1)) NOT NULL,
    [hideColumn]       INT              CONSTRAINT [DF_c129592ba11777b17e9336b519d] DEFAULT ((1)) NOT NULL,
    [displayName]      NVARCHAR (MAX)   NULL,
    [description]      NVARCHAR (MAX)   NULL,
    [status]           INT              CONSTRAINT [DF_ccb7684e967198616303d079afd] DEFAULT ((10)) NOT NULL,
    [createdBy]        NVARCHAR (128)   NOT NULL,
    [updatedBy]        NVARCHAR (128)   NOT NULL,
    [createdAt]        INT              NOT NULL,
    [updatedAt]        INT              NOT NULL,
    [recordGuid]       UNIQUEIDENTIFIER CONSTRAINT [DF_powertable_column_config_recordGuid] DEFAULT (newsequentialid()) NOT NULL,
    CONSTRAINT [PK_9d57affe091648e10a660e0b6cc] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_861df9ce80f8cd19e53d376dbcb] FOREIGN KEY ([sourceId]) REFERENCES [4f48cf63-7c36-4ac3-9f09-a1d413854e4d].[powertable_source] ([id])
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_powertable_column_config_recordGuid]
    ON [4f48cf63-7c36-4ac3-9f09-a1d413854e4d].[powertable_column_config]([recordGuid] ASC);


GO

