CREATE TABLE [52033849-181f-483f-b67d-f35f0ed7634c].[planning_snapshot] (
    [id]        INT            IDENTITY (1, 1) NOT NULL,
    [visualId]  INT            NOT NULL,
    [name]      VARCHAR (255)  NOT NULL,
    [meta]      NVARCHAR (MAX) NULL,
    [status]    INT            CONSTRAINT [DF_3bb68ef236f0a73c53cacca0848] DEFAULT ((10)) NOT NULL,
    [createdBy] NVARCHAR (128) NOT NULL,
    [updatedBy] NVARCHAR (128) NOT NULL,
    [createdAt] INT            NOT NULL,
    [updatedAt] INT            NOT NULL,
    CONSTRAINT [PK_837b4bb162bc91625857697f10a] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO

