CREATE TABLE [0d2c47cd-6740-4e30-9d88-b815bab60653].[powertable_approval_request_logs] (
    [id]                INT            IDENTITY (1, 1) NOT NULL,
    [approvalRequestId] INT            NOT NULL,
    [eventCode]         VARCHAR (255)  NOT NULL,
    [eventValue]        NVARCHAR (MAX) NOT NULL,
    [meta]              NVARCHAR (MAX) NOT NULL,
    [sourceJobId]       INT            NULL,
    [approvalLevel]     INT            NULL,
    [status]            INT            CONSTRAINT [DF_712b585ee3c4d0c864b88dec377] DEFAULT ((10)) NOT NULL,
    [createdBy]         NVARCHAR (128) NOT NULL,
    [updatedBy]         NVARCHAR (128) NOT NULL,
    [createdAt]         INT            NOT NULL,
    [updatedAt]         INT            NOT NULL,
    CONSTRAINT [PK_da4acde3e2ac65b6ce2ad87644e] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_f93b73db3abf98a99f7f3ed6092] FOREIGN KEY ([approvalRequestId]) REFERENCES [0d2c47cd-6740-4e30-9d88-b815bab60653].[powertable_approval_request] ([id])
);


GO

