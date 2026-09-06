CREATE TABLE [abf29c97-6605-42db-bf40-988a0419387f].[cube_partition_measure_mapping] (
    [id]                     INT              IDENTITY (1, 1) NOT NULL,
    [cubePartitionId]        INT              NOT NULL,
    [cubePartitionMeasureId] INT              NOT NULL,
    [status]                 INT              CONSTRAINT [DF_293041d9f6026978b5550ae537a] DEFAULT ((10)) NOT NULL,
    [createdBy]              NVARCHAR (128)   NOT NULL,
    [updatedBy]              NVARCHAR (128)   NOT NULL,
    [createdAt]              INT              NOT NULL,
    [updatedAt]              INT              NOT NULL,
    [recordGuid]             UNIQUEIDENTIFIER CONSTRAINT [DF_cube_partition_measure_mapping_recordGuid] DEFAULT (newsequentialid()) NOT NULL,
    CONSTRAINT [PK_f34cb25b2bdfd259c81eb680524] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_1a0ec11f69f8a66ca96a70f6898] FOREIGN KEY ([cubePartitionMeasureId]) REFERENCES [abf29c97-6605-42db-bf40-988a0419387f].[cube_partition_measure] ([id]),
    CONSTRAINT [FK_45397800a3e0792e04f50881a01] FOREIGN KEY ([cubePartitionId]) REFERENCES [abf29c97-6605-42db-bf40-988a0419387f].[cube_partition] ([id])
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_cube_partition_measure_mapping_recordGuid]
    ON [abf29c97-6605-42db-bf40-988a0419387f].[cube_partition_measure_mapping]([recordGuid] ASC);


GO

