CREATE TABLE [562059f4-3c4c-407c-8a2c-864f2acbe25c].[forecast_user_access] (
    [id]                  INT            IDENTITY (1, 1) NOT NULL,
    [visualId]            INT            NULL,
    [dataInputColumnGuid] VARCHAR (255)  NOT NULL,
    [accessEntityType]    INT            NOT NULL,
    [accessEntityId]      VARCHAR (128)  NOT NULL,
    [status]              INT            CONSTRAINT [DF_7ad8e1774a319e66544cc7d5995] DEFAULT ((10)) NOT NULL,
    [createdBy]           NVARCHAR (128) NOT NULL,
    [updatedBy]           NVARCHAR (128) NOT NULL,
    [createdAt]           INT            NOT NULL,
    [updatedAt]           INT            NOT NULL,
    CONSTRAINT [PK_50b700ca4d9cf33f748bc70f1c3] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO

