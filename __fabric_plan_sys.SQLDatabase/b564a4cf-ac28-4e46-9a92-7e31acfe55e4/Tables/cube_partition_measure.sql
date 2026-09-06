CREATE TABLE [b564a4cf-ac28-4e46-9a92-7e31acfe55e4].[cube_partition_measure] (
    [id]         INT              IDENTITY (1, 1) NOT NULL,
    [name]       VARCHAR (255)    NOT NULL,
    [config]     NVARCHAR (MAX)   NULL,
    [type]       INT              NOT NULL,
    [status]     INT              CONSTRAINT [DF_682911df79beab606581e6c1e2c] DEFAULT ((10)) NOT NULL,
    [createdBy]  NVARCHAR (128)   NOT NULL,
    [updatedBy]  NVARCHAR (128)   NOT NULL,
    [createdAt]  INT              NOT NULL,
    [updatedAt]  INT              NOT NULL,
    [recordGuid] UNIQUEIDENTIFIER CONSTRAINT [DF_cube_partition_measure_recordGuid] DEFAULT (newsequentialid()) NOT NULL,
    CONSTRAINT [PK_7ac191e42d6a5b17f9b8fd96571] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_cube_partition_measure_recordGuid]
    ON [b564a4cf-ac28-4e46-9a92-7e31acfe55e4].[cube_partition_measure]([recordGuid] ASC);


GO

