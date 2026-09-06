CREATE TABLE [5f84b3cd-bbf9-46b2-84dc-908807160020].[powertable_approval_level] (
    [id]          INT              IDENTITY (1, 1) NOT NULL,
    [approvalId]  INT              NOT NULL,
    [name]        VARCHAR (255)    NOT NULL,
    [description] VARCHAR (255)    NOT NULL,
    [level]       INT              CONSTRAINT [DF_7772b5b22e1bfd90ef04a407e50] DEFAULT ((1)) NOT NULL,
    [status]      INT              CONSTRAINT [DF_dc5c676949f2b2c3f068851d947] DEFAULT ((10)) NOT NULL,
    [createdBy]   NVARCHAR (128)   NOT NULL,
    [updatedBy]   NVARCHAR (128)   NOT NULL,
    [createdAt]   INT              NOT NULL,
    [updatedAt]   INT              NOT NULL,
    [recordGuid]  UNIQUEIDENTIFIER CONSTRAINT [DF_powertable_approval_level_recordGuid] DEFAULT (newsequentialid()) NOT NULL,
    CONSTRAINT [PK_423a6b7d4fe4163af1d7c56fddb] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_c83f41d1a622e4368ad562c3310] FOREIGN KEY ([approvalId]) REFERENCES [5f84b3cd-bbf9-46b2-84dc-908807160020].[powertable_approval] ([id])
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_powertable_approval_level_recordGuid]
    ON [5f84b3cd-bbf9-46b2-84dc-908807160020].[powertable_approval_level]([recordGuid] ASC);


GO

