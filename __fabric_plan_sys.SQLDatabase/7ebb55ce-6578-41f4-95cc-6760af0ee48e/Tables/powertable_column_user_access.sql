CREATE TABLE [7ebb55ce-6578-41f4-95cc-6760af0ee48e].[powertable_column_user_access] (
    [id]               INT            IDENTITY (1, 1) NOT NULL,
    [columnConfigId]   INT            NOT NULL,
    [accessEntityId]   VARCHAR (128)  NOT NULL,
    [accessEntityType] INT            NOT NULL,
    [permissionType]   INT            NOT NULL,
    [status]           INT            CONSTRAINT [DF_627639fbc89ec6ebf8fb60c315e] DEFAULT ((10)) NOT NULL,
    [createdBy]        NVARCHAR (128) NOT NULL,
    [updatedBy]        NVARCHAR (128) NOT NULL,
    [createdAt]        INT            NOT NULL,
    [updatedAt]        INT            NOT NULL,
    CONSTRAINT [PK_017e468771f15fc852e7e8249bd] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_7b43e70fbe0554d3ebc7f60a708] FOREIGN KEY ([columnConfigId]) REFERENCES [7ebb55ce-6578-41f4-95cc-6760af0ee48e].[powertable_column_config] ([id])
);


GO

