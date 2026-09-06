CREATE TABLE [1b81b45c-751e-46d6-9081-18225b0e9011].[writeback_user_access] (
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
    CONSTRAINT [FK_42151e9d7274a51029ddc9a451a] FOREIGN KEY ([visualId]) REFERENCES [1b81b45c-751e-46d6-9081-18225b0e9011].[visual] ([id])
);


GO

