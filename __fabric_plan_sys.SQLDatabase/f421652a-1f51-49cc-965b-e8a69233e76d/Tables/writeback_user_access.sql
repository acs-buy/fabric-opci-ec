CREATE TABLE [f421652a-1f51-49cc-965b-e8a69233e76d].[writeback_user_access] (
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
    CONSTRAINT [FK_42151e9d7274a51029ddc9a451a] FOREIGN KEY ([visualId]) REFERENCES [f421652a-1f51-49cc-965b-e8a69233e76d].[visual] ([id])
);


GO

