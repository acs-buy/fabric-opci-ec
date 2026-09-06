CREATE TABLE [2b06b4a7-d5c3-4748-89a6-31d60790423e].[writeback_settings] (
    [id]         INT              IDENTITY (1, 1) NOT NULL,
    [visualId]   INT              NOT NULL,
    [meta]       NVARCHAR (MAX)   NOT NULL,
    [status]     INT              CONSTRAINT [DF_9f10efbc84449f82c18a246129c] DEFAULT ((10)) NOT NULL,
    [createdBy]  NVARCHAR (128)   NOT NULL,
    [updatedBy]  NVARCHAR (128)   NOT NULL,
    [createdAt]  INT              NOT NULL,
    [updatedAt]  INT              NOT NULL,
    [recordGuid] UNIQUEIDENTIFIER CONSTRAINT [DF_writeback_settings_recordGuid] DEFAULT (newsequentialid()) NOT NULL,
    CONSTRAINT [PK_f7667e00688b086e1292e6615a2] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_94e8f3168953c07cd61ff067f34] FOREIGN KEY ([visualId]) REFERENCES [2b06b4a7-d5c3-4748-89a6-31d60790423e].[visual] ([id])
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_writeback_settings_recordGuid]
    ON [2b06b4a7-d5c3-4748-89a6-31d60790423e].[writeback_settings]([recordGuid] ASC);


GO

