CREATE TABLE [2b06b4a7-d5c3-4748-89a6-31d60790423e].[cube_partition_sync_logs] (
    [id]                   INT            IDENTITY (1, 1) NOT NULL,
    [uniqueGuid]           VARCHAR (255)  NOT NULL,
    [syncedBreakdownCount] INT            CONSTRAINT [DF_1a57bf7860afe103658ea9d50ad] DEFAULT ((0)) NOT NULL,
    [partitionMeasureId]   INT            NOT NULL,
    [errorMeta]            NVARCHAR (MAX) NULL,
    [status]               INT            CONSTRAINT [DF_e28bb82233d8a33b02020c5df0a] DEFAULT ((10)) NOT NULL,
    [createdBy]            NVARCHAR (128) NOT NULL,
    [updatedBy]            NVARCHAR (128) NOT NULL,
    [createdAt]            INT            NOT NULL,
    [updatedAt]            INT            NOT NULL,
    CONSTRAINT [PK_5388f13a49ba561bb70bf0e5757] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_c178596a53d6c303773a9095a21] FOREIGN KEY ([partitionMeasureId]) REFERENCES [2b06b4a7-d5c3-4748-89a6-31d60790423e].[cube_partition_measure] ([id])
);


GO

CREATE NONCLUSTERED INDEX [idx_cube_partition_sync_logs_partitionMeasureId]
    ON [2b06b4a7-d5c3-4748-89a6-31d60790423e].[cube_partition_sync_logs]([partitionMeasureId] ASC) WHERE ([status]<>(500));


GO

