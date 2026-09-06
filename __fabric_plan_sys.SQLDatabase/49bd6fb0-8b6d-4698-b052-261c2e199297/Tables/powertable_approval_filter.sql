CREATE TABLE [49bd6fb0-8b6d-4698-b052-261c2e199297].[powertable_approval_filter] (
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
    CONSTRAINT [FK_94539a8181a5a4dc2ea1ea42a12] FOREIGN KEY ([approvalId]) REFERENCES [49bd6fb0-8b6d-4698-b052-261c2e199297].[powertable_approval] ([id])
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_powertable_approval_filter_recordGuid]
    ON [49bd6fb0-8b6d-4698-b052-261c2e199297].[powertable_approval_filter]([recordGuid] ASC);


GO

