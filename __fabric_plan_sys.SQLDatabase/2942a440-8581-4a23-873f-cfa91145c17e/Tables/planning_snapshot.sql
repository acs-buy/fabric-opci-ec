CREATE TABLE [2942a440-8581-4a23-873f-cfa91145c17e].[planning_snapshot] (
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

