CREATE TABLE [2b06b4a7-d5c3-4748-89a6-31d60790423e].[writeback] (
    [id]              INT            IDENTITY (1, 1) NOT NULL,
    [visualId]        INT            NOT NULL,
    [executionId]     VARCHAR (255)  NULL,
    [payloadFileName] VARCHAR (255)  NULL,
    [meta]            NVARCHAR (MAX) NOT NULL,
    [destinationMeta] NVARCHAR (MAX) NOT NULL,
    [startTime]       INT            NULL,
    [endTime]         INT            NULL,
    [scenarioIds]     VARCHAR (255)  NOT NULL,
    [snapshotName]    VARCHAR (255)  NULL,
    [errorMeta]       NVARCHAR (MAX) NULL,
    [createdByUPN]    NVARCHAR (320) NOT NULL,
    [status]          INT            CONSTRAINT [DF_cfc6a0f2dde7b32c72bfe362f0b] DEFAULT ((10)) NOT NULL,
    [createdBy]       NVARCHAR (128) NOT NULL,
    [updatedBy]       NVARCHAR (128) NOT NULL,
    [createdAt]       INT            NOT NULL,
    [updatedAt]       INT            NOT NULL,
    CONSTRAINT [PK_bc4386131613b363d758d5592da] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_bbc1ed3d35bb48f8c0823c361c0] FOREIGN KEY ([visualId]) REFERENCES [2b06b4a7-d5c3-4748-89a6-31d60790423e].[visual] ([id])
);


GO

