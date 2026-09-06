CREATE TABLE [5df03107-c058-4934-9696-943dffe44c90].[powertable_form_url_user_access] (
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
    CONSTRAINT [FK_d49e613b80d39d9d2850fc998e7] FOREIGN KEY ([formUrlId]) REFERENCES [5df03107-c058-4934-9696-943dffe44c90].[powertable_form_urls] ([id])
);


GO

