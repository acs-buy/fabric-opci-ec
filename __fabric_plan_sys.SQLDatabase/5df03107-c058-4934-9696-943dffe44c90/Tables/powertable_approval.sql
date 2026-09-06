CREATE TABLE [5df03107-c058-4934-9696-943dffe44c90].[powertable_approval] (
    [id]                INT              IDENTITY (1, 1) NOT NULL,
    [sourceId]          INT              NOT NULL,
    [settings]          NVARCHAR (MAX)   NULL,
    [persistFlag]       INT              CONSTRAINT [DF_26b3cfd370eda7b75c36adbae00] DEFAULT ((0)) NOT NULL,
    [ruleType]          INT              CONSTRAINT [DF_9831548e24d07199bd6695c9f30] DEFAULT ((1)) NOT NULL,
    [multiLevelEnabled] INT              CONSTRAINT [DF_113835eedfc93123c26ebbf385e] DEFAULT ((0)) NOT NULL,
    [approvalLevel]     INT              NULL,
    [status]            INT              CONSTRAINT [DF_f29ae8036d6d40d34b56dda50c7] DEFAULT ((10)) NOT NULL,
    [createdBy]         NVARCHAR (128)   NOT NULL,
    [updatedBy]         NVARCHAR (128)   NOT NULL,
    [createdAt]         INT              NOT NULL,
    [updatedAt]         INT              NOT NULL,
    [recordGuid]        UNIQUEIDENTIFIER CONSTRAINT [DF_powertable_approval_recordGuid] DEFAULT (newsequentialid()) NOT NULL,
    CONSTRAINT [PK_ed6b50de16c68c19e82d2b72839] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_4dc3ff09cd30268621a118617d8] FOREIGN KEY ([sourceId]) REFERENCES [5df03107-c058-4934-9696-943dffe44c90].[powertable_source] ([id])
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_powertable_approval_recordGuid]
    ON [5df03107-c058-4934-9696-943dffe44c90].[powertable_approval]([recordGuid] ASC);


GO

