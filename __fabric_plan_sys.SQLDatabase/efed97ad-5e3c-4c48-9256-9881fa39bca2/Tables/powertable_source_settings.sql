CREATE TABLE [efed97ad-5e3c-4c48-9256-9881fa39bca2].[powertable_source_settings] (
    [id]         INT              IDENTITY (1, 1) NOT NULL,
    [sourceId]   INT              NULL,
    [name]       VARCHAR (255)    NOT NULL,
    [settings]   NVARCHAR (MAX)   NOT NULL,
    [status]     INT              CONSTRAINT [DF_b9ef74fa4dcf80bd5d9e46eea24] DEFAULT ((10)) NOT NULL,
    [createdBy]  NVARCHAR (128)   NOT NULL,
    [updatedBy]  NVARCHAR (128)   NOT NULL,
    [createdAt]  INT              NOT NULL,
    [updatedAt]  INT              NOT NULL,
    [recordGuid] UNIQUEIDENTIFIER CONSTRAINT [DF_powertable_source_settings_recordGuid] DEFAULT (newsequentialid()) NOT NULL,
    CONSTRAINT [PK_86d8752dbe70afea9d1c924a502] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_aca67c695d159618d8bcdbc163f] FOREIGN KEY ([sourceId]) REFERENCES [efed97ad-5e3c-4c48-9256-9881fa39bca2].[powertable_source] ([id])
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_powertable_source_settings_recordGuid]
    ON [efed97ad-5e3c-4c48-9256-9881fa39bca2].[powertable_source_settings]([recordGuid] ASC);


GO

