CREATE TABLE [562059f4-3c4c-407c-8a2c-864f2acbe25c].[powertable_form_url_user_access] (
    [id]               INT            IDENTITY (1, 1) NOT NULL,
    [formUrlId]        INT            NOT NULL,
    [accessEntityId]   VARCHAR (128)  NOT NULL,
    [accessEntityType] INT            NOT NULL,
    [status]           INT            CONSTRAINT [DF_ab6a75ba720f3587a7684bb08dc] DEFAULT ((10)) NOT NULL,
    [createdBy]        NVARCHAR (128) NOT NULL,
    [updatedBy]        NVARCHAR (128) NOT NULL,
    [createdAt]        INT            NOT NULL,
    [updatedAt]        INT            NOT NULL,
    CONSTRAINT [PK_5d8204c4277d1063c6a9555062f] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_d49e613b80d39d9d2850fc998e7] FOREIGN KEY ([formUrlId]) REFERENCES [562059f4-3c4c-407c-8a2c-864f2acbe25c].[powertable_form_urls] ([id])
);


GO

