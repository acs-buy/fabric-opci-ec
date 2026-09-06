CREATE TABLE [7ebb55ce-6578-41f4-95cc-6760af0ee48e].[planning_snapshot_user_access] (
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

