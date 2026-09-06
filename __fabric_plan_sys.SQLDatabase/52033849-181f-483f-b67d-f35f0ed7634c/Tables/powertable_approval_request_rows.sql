CREATE TABLE [52033849-181f-483f-b67d-f35f0ed7634c].[powertable_approval_request_rows] (
    [id]                INT            IDENTITY (1, 1) NOT NULL,
    [approvalRequestId] INT            NOT NULL,
    [rowId]             NVARCHAR (MAX) NOT NULL,
    [syncStatus]        INT            CONSTRAINT [DF_892ddc5eab3b2818e5e728e77de] DEFAULT ((10)) NOT NULL,
    [status]            INT            CONSTRAINT [DF_7cce3fe577b0221b7633f6b1fa8] DEFAULT ((10)) NOT NULL,
    [createdBy]         NVARCHAR (128) NOT NULL,
    [updatedBy]         NVARCHAR (128) NOT NULL,
    [createdAt]         INT            NOT NULL,
    [updatedAt]         INT            NOT NULL,
    [rowMeta]           NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_b5f8c0032098785bf2d4367dd0f] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_a782d5b8982a5f441a565c1fa12] FOREIGN KEY ([approvalRequestId]) REFERENCES [52033849-181f-483f-b67d-f35f0ed7634c].[powertable_approval_request] ([id])
);


GO

