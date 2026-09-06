CREATE TABLE [1b81b45c-751e-46d6-9081-18225b0e9011].[onelake_sync_state] (
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

