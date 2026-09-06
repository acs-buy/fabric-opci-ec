CREATE TABLE [52033849-181f-483f-b67d-f35f0ed7634c].[scenario_user_access] (
    [id]               INT            IDENTITY (1, 1) NOT NULL,
    [scenarioGuid]     VARCHAR (255)  NOT NULL,
    [accessEntityType] INT            NOT NULL,
    [accessEntityId]   VARCHAR (128)  NOT NULL,
    [visualId]         INT            NULL,
    [status]           INT            CONSTRAINT [DF_536456c29e124169a0e0f6b3591] DEFAULT ((10)) NOT NULL,
    [createdBy]        NVARCHAR (128) NOT NULL,
    [updatedBy]        NVARCHAR (128) NOT NULL,
    [createdAt]        INT            NOT NULL,
    [updatedAt]        INT            NOT NULL,
    CONSTRAINT [PK_d21f124a9d85a9f25245c0ad15a] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_7d45df30d814c3c43ba40e48d84] FOREIGN KEY ([visualId]) REFERENCES [52033849-181f-483f-b67d-f35f0ed7634c].[visual] ([id])
);


GO

