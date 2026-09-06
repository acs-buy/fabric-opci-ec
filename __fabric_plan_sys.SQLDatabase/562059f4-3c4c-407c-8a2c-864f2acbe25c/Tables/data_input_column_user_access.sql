CREATE TABLE [562059f4-3c4c-407c-8a2c-864f2acbe25c].[data_input_column_user_access] (
    [id]                   INT            IDENTITY (1, 1) NOT NULL,
    [visualId]             INT            NOT NULL,
    [dataInputColumnGuid]  VARCHAR (255)  NOT NULL,
    [accessEntityType]     INT            NOT NULL,
    [accessEntityId]       VARCHAR (128)  NOT NULL,
    [accessPermissionType] INT            NOT NULL,
    [status]               INT            CONSTRAINT [DF_9c6a1ef1b3972441bd1a0316c3e] DEFAULT ((10)) NOT NULL,
    [createdBy]            NVARCHAR (128) NOT NULL,
    [updatedBy]            NVARCHAR (128) NOT NULL,
    [createdAt]            INT            NOT NULL,
    [updatedAt]            INT            NOT NULL,
    CONSTRAINT [PK_00c743e7db851e40ab25666ebf8] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO

