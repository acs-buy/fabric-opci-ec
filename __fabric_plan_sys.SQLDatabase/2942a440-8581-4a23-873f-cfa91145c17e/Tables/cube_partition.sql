CREATE TABLE [2942a440-8581-4a23-873f-cfa91145c17e].[cube_partition] (
    [id]             INT              IDENTITY (1, 1) NOT NULL,
    [name]           VARCHAR (255)    NOT NULL,
    [dimensions]     NVARCHAR (MAX)   NOT NULL,
    [timeDimensions] NVARCHAR (MAX)   NOT NULL,
    [measures]       NVARCHAR (MAX)   NOT NULL,
    [rowCount]       INT              NULL,
    [lastSyncAt]     INT              NULL,
    [lastSyncBy]     NVARCHAR (36)    NULL,
    [status]         INT              CONSTRAINT [DF_9fe34c44ca1061192fe45ab4034] DEFAULT ((10)) NOT NULL,
    [createdBy]      NVARCHAR (128)   NOT NULL,
    [updatedBy]      NVARCHAR (128)   NOT NULL,
    [createdAt]      INT              NOT NULL,
    [updatedAt]      INT              NOT NULL,
    [recordGuid]     UNIQUEIDENTIFIER CONSTRAINT [DF_cube_partition_recordGuid] DEFAULT (newsequentialid()) NOT NULL,
    CONSTRAINT [PK_d91dd3d75604cd2e3f1810d3b56] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_cube_partition_recordGuid]
    ON [2942a440-8581-4a23-873f-cfa91145c17e].[cube_partition]([recordGuid] ASC);


GO

