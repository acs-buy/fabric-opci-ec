CREATE TABLE [1b81b45c-751e-46d6-9081-18225b0e9011].[data_input_column_user_access] (
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

