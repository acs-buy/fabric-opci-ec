CREATE TABLE [a17b18e9-b7f7-4bd9-b911-cf436bc66b7a].[planning_snapshot_user_access] (
    [id]               INT            IDENTITY (1, 1) NOT NULL,
    [visualId]         INT            NULL,
    [accessEntityType] INT            NOT NULL,
    [accessEntityId]   VARCHAR (128)  NOT NULL,
    [status]           INT            CONSTRAINT [DF_0d6fb5226695af9bd5a9612ffa2] DEFAULT ((10)) NOT NULL,
    [createdBy]        NVARCHAR (128) NOT NULL,
    [updatedBy]        NVARCHAR (128) NOT NULL,
    [createdAt]        INT            NOT NULL,
    [updatedAt]        INT            NOT NULL,
    CONSTRAINT [PK_223746be798c0b5b066b702bcc7] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO

