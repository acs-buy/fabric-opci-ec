CREATE TABLE [abf29c97-6605-42db-bf40-988a0419387f].[powertable_forms] (
    [id]                    INT              IDENTITY (1, 1) NOT NULL,
    [sourceId]              INT              NOT NULL,
    [title]                 VARCHAR (255)    NOT NULL,
    [description]           VARCHAR (255)    NOT NULL,
    [restrictMultipleEntry] INT              CONSTRAINT [DF_786b700ed9f3611df6da869c1ad] DEFAULT ((0)) NOT NULL,
    [logo]                  NVARCHAR (MAX)   NULL,
    [config]                NVARCHAR (MAX)   NULL,
    [layoutMeta]            NVARCHAR (MAX)   NULL,
    [status]                INT              CONSTRAINT [DF_df7ecfb940104b11e52f460d494] DEFAULT ((10)) NOT NULL,
    [createdBy]             NVARCHAR (128)   NOT NULL,
    [updatedBy]             NVARCHAR (128)   NOT NULL,
    [createdAt]             INT              NOT NULL,
    [updatedAt]             INT              NOT NULL,
    [recordGuid]            UNIQUEIDENTIFIER CONSTRAINT [DF_powertable_forms_recordGuid] DEFAULT (newsequentialid()) NOT NULL,
    CONSTRAINT [PK_bf07960293aa1a078c3454cb44d] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_64f3daea4f2056ece36b93069fa] FOREIGN KEY ([sourceId]) REFERENCES [abf29c97-6605-42db-bf40-988a0419387f].[powertable_source] ([id])
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_powertable_forms_recordGuid]
    ON [abf29c97-6605-42db-bf40-988a0419387f].[powertable_forms]([recordGuid] ASC);


GO

