CREATE TABLE [b564a4cf-ac28-4e46-9a92-7e31acfe55e4].[onelake_sync_state] (
    [id]         INT           IDENTITY (1, 1) NOT NULL,
    [name]       VARCHAR (255) NOT NULL,
    [path]       VARCHAR (450) NOT NULL,
    [syncStatus] INT           NULL,
    [createdAt]  INT           NULL,
    [updatedAt]  INT           NULL,
    CONSTRAINT [PK_onelake_sync_state] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [UQ_onelake_sync_state_path] UNIQUE NONCLUSTERED ([path] ASC)
);


GO

