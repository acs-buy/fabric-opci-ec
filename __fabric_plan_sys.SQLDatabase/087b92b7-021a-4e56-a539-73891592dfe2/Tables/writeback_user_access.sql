CREATE TABLE [087b92b7-021a-4e56-a539-73891592dfe2].[writeback_user_access] (
    [id]               INT            IDENTITY (1, 1) NOT NULL,
    [visualId]         INT            NOT NULL,
    [accessEntityType] INT            NOT NULL,
    [accessEntityId]   VARCHAR (128)  NOT NULL,
    [status]           INT            CONSTRAINT [DF_62edf503648a2f8918929854ec8] DEFAULT ((10)) NOT NULL,
    [createdBy]        NVARCHAR (128) NOT NULL,
    [updatedBy]        NVARCHAR (128) NOT NULL,
    [createdAt]        INT            NOT NULL,
    [updatedAt]        INT            NOT NULL,
    CONSTRAINT [PK_d633d0e7deb770beaf8967d8876] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_42151e9d7274a51029ddc9a451a] FOREIGN KEY ([visualId]) REFERENCES [087b92b7-021a-4e56-a539-73891592dfe2].[visual] ([id])
);


GO

