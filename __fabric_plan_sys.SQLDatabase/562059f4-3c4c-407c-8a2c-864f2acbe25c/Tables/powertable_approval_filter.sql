CREATE TABLE [562059f4-3c4c-407c-8a2c-864f2acbe25c].[powertable_approval_filter] (
    [id]         INT              IDENTITY (1, 1) NOT NULL,
    [name]       VARCHAR (255)    NOT NULL,
    [approvalId] INT              NOT NULL,
    [filter]     NVARCHAR (MAX)   NULL,
    [order]      INT              NOT NULL,
    [status]     INT              CONSTRAINT [DF_b773a455b72b9b17706d6acc934] DEFAULT ((10)) NOT NULL,
    [createdBy]  NVARCHAR (128)   NOT NULL,
    [updatedBy]  NVARCHAR (128)   NOT NULL,
    [createdAt]  INT              NOT NULL,
    [updatedAt]  INT              NOT NULL,
    [recordGuid] UNIQUEIDENTIFIER CONSTRAINT [DF_powertable_approval_filter_recordGuid] DEFAULT (newsequentialid()) NOT NULL,
    CONSTRAINT [PK_cff98616d4f09ceb656cd00db6d] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_94539a8181a5a4dc2ea1ea42a12] FOREIGN KEY ([approvalId]) REFERENCES [562059f4-3c4c-407c-8a2c-864f2acbe25c].[powertable_approval] ([id])
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_powertable_approval_filter_recordGuid]
    ON [562059f4-3c4c-407c-8a2c-864f2acbe25c].[powertable_approval_filter]([recordGuid] ASC);


GO

