CREATE TABLE [1b81b45c-751e-46d6-9081-18225b0e9011].[powertable_approval_filter_users] (
    [id]               INT            IDENTITY (1, 1) NOT NULL,
    [filterId]         INT            NOT NULL,
    [approvalLevelId]  INT            NOT NULL,
    [accessEntityId]   VARCHAR (128)  NOT NULL,
    [accessEntityType] INT            NOT NULL,
    [status]           INT            CONSTRAINT [DF_79925cb52de8078e418b62bacd4] DEFAULT ((10)) NOT NULL,
    [createdBy]        NVARCHAR (128) NOT NULL,
    [updatedBy]        NVARCHAR (128) NOT NULL,
    [createdAt]        INT            NOT NULL,
    [updatedAt]        INT            NOT NULL,
    CONSTRAINT [PK_910313c5e97bac630ffbcdb9535] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_37a2ef9e63e9b522309cefebddc] FOREIGN KEY ([filterId]) REFERENCES [1b81b45c-751e-46d6-9081-18225b0e9011].[powertable_approval_filter] ([id])
);


GO

