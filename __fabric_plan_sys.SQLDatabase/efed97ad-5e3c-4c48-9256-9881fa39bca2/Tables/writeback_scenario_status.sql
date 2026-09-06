CREATE TABLE [efed97ad-5e3c-4c48-9256-9881fa39bca2].[writeback_scenario_status] (
    [id]                INT            IDENTITY (1, 1) NOT NULL,
    [visualId]          INT            NOT NULL,
    [scenarioId]        INT            NULL,
    [lastWritebackTime] INT            NOT NULL,
    [status]            INT            CONSTRAINT [DF_407b9342e8f2d630379a320707a] DEFAULT ((10)) NOT NULL,
    [createdBy]         NVARCHAR (128) NOT NULL,
    [updatedBy]         NVARCHAR (128) NOT NULL,
    [createdAt]         INT            NOT NULL,
    [updatedAt]         INT            NOT NULL,
    CONSTRAINT [PK_79824f9a5588367231a7b505a96] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_0b75c6baffff89c43691a946133] FOREIGN KEY ([visualId]) REFERENCES [efed97ad-5e3c-4c48-9256-9881fa39bca2].[visual] ([id])
);


GO

