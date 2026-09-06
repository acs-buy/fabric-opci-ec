CREATE TABLE [087b92b7-021a-4e56-a539-73891592dfe2].[approval_column_user_access] (
    [id]                   INT            IDENTITY (1, 1) NOT NULL,
    [visualId]             INT            NOT NULL,
    [dataInputColumnGuid]  VARCHAR (255)  NOT NULL,
    [accessEntityType]     INT            NOT NULL,
    [accessEntityId]       VARCHAR (128)  NOT NULL,
    [accessPermissionType] INT            NOT NULL,
    [status]               INT            CONSTRAINT [DF_approval_column_user_access_status] DEFAULT ((10)) NOT NULL,
    [createdBy]            NVARCHAR (128) NOT NULL,
    [updatedBy]            NVARCHAR (128) NOT NULL,
    [createdAt]            INT            NOT NULL,
    [updatedAt]            INT            NOT NULL,
    CONSTRAINT [PK_approval_column_user_access] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO

