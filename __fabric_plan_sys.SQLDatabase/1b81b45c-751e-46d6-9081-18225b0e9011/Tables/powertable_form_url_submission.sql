CREATE TABLE [1b81b45c-751e-46d6-9081-18225b0e9011].[powertable_form_url_submission] (
    [id]          INT            IDENTITY (1, 1) NOT NULL,
    [formUrlId]   INT            NOT NULL,
    [formData]    NVARCHAR (MAX) NOT NULL,
    [sourceJobId] INT            NULL,
    [status]      INT            CONSTRAINT [DF_022f7ed8db8757f82a09c68888a] DEFAULT ((10)) NOT NULL,
    [createdBy]   NVARCHAR (128) NOT NULL,
    [updatedBy]   NVARCHAR (128) NOT NULL,
    [createdAt]   INT            NOT NULL,
    [updatedAt]   INT            NOT NULL,
    CONSTRAINT [PK_ef7b9238985c5d44024f47fd6bd] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_a243f830af56802871c62c9330a] FOREIGN KEY ([formUrlId]) REFERENCES [1b81b45c-751e-46d6-9081-18225b0e9011].[powertable_form_urls] ([id])
);


GO

