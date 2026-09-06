CREATE TABLE [90f6b4d0-829e-4f62-91eb-204c8bf56be7].[cube_partition_sync_logs] (
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
    CONSTRAINT [FK_c178596a53d6c303773a9095a21] FOREIGN KEY ([partitionMeasureId]) REFERENCES [90f6b4d0-829e-4f62-91eb-204c8bf56be7].[cube_partition_measure] ([id])
);


GO

CREATE NONCLUSTERED INDEX [idx_cube_partition_sync_logs_partitionMeasureId]
    ON [90f6b4d0-829e-4f62-91eb-204c8bf56be7].[cube_partition_sync_logs]([partitionMeasureId] ASC) WHERE ([status]<>(500));


GO

