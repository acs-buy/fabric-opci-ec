CREATE TABLE [efed97ad-5e3c-4c48-9256-9881fa39bca2].[powertable_visual_source] (
    [id]         INT              IDENTITY (1, 1) NOT NULL,
    [visualId]   INT              NOT NULL,
    [sourceId]   INT              NOT NULL,
    [status]     INT              CONSTRAINT [DF_af2b9acbbac7d2021445bfc43d6] DEFAULT ((10)) NOT NULL,
    [createdBy]  NVARCHAR (128)   NOT NULL,
    [updatedBy]  NVARCHAR (128)   NOT NULL,
    [createdAt]  INT              NOT NULL,
    [updatedAt]  INT              NOT NULL,
    [recordGuid] UNIQUEIDENTIFIER CONSTRAINT [DF_powertable_visual_source_recordGuid] DEFAULT (newsequentialid()) NOT NULL,
    CONSTRAINT [PK_0c26bad688242783eff7c5d4912] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_2d2674056f7c38b4b62b2b3c7e4] FOREIGN KEY ([sourceId]) REFERENCES [efed97ad-5e3c-4c48-9256-9881fa39bca2].[powertable_source] ([id]),
    CONSTRAINT [FK_40aea1c78e8c4b9ded7a7e28ee5] FOREIGN KEY ([visualId]) REFERENCES [efed97ad-5e3c-4c48-9256-9881fa39bca2].[visual] ([id])
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_powertable_visual_source_recordGuid]
    ON [efed97ad-5e3c-4c48-9256-9881fa39bca2].[powertable_visual_source]([recordGuid] ASC);


GO

