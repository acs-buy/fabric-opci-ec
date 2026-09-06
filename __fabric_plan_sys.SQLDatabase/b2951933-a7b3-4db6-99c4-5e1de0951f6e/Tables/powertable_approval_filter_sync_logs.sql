CREATE TABLE [b2951933-a7b3-4db6-99c4-5e1de0951f6e].[powertable_approval_filter_sync_logs] (
    [id]         INT            IDENTITY (1, 1) NOT NULL,
    [approvalId] INT            NOT NULL,
    [meta]       NVARCHAR (MAX) NOT NULL,
    [errorMsg]   NVARCHAR (MAX) NULL,
    [status]     INT            NOT NULL,
    [createdBy]  NVARCHAR (128) NOT NULL,
    [updatedBy]  NVARCHAR (128) NOT NULL,
    [createdAt]  INT            NOT NULL,
    [updatedAt]  INT            NOT NULL,
    CONSTRAINT [PK_9366cad86c47bb89df427864217] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_c853e65e969e2795b8888dcc1ce] FOREIGN KEY ([approvalId]) REFERENCES [b2951933-a7b3-4db6-99c4-5e1de0951f6e].[powertable_approval] ([id])
);


GO

