CREATE TABLE [0d2c47cd-6740-4e30-9d88-b815bab60653].[powertable_notification] (
    [id]         INT            IDENTITY (1, 1) NOT NULL,
    [entityId]   INT            NOT NULL,
    [entityType] INT            NOT NULL,
    [provider]   INT            NOT NULL,
    [settings]   NVARCHAR (MAX) NOT NULL,
    [status]     INT            CONSTRAINT [DF_5904adfb3e7f681909fc95615bb] DEFAULT ((10)) NOT NULL,
    [createdBy]  NVARCHAR (128) NOT NULL,
    [updatedBy]  NVARCHAR (128) NOT NULL,
    [createdAt]  INT            NOT NULL,
    [updatedAt]  INT            NOT NULL,
    CONSTRAINT [PK_b12751b8aaf393882e056dfe293] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO

