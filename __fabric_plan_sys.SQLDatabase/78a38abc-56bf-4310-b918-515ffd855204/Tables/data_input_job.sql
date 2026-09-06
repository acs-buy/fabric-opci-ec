CREATE TABLE [78a38abc-56bf-4310-b918-515ffd855204].[data_input_job] (
    [id]        INT            IDENTITY (1, 1) NOT NULL,
    [visualId]  INT            NOT NULL,
    [type]      INT            NOT NULL,
    [startTime] INT            NULL,
    [endTime]   INT            NULL,
    [errorMeta] NVARCHAR (MAX) NULL,
    [status]    INT            CONSTRAINT [DF_63730597c72edd18f358f75f190] DEFAULT ((10)) NOT NULL,
    [createdBy] NVARCHAR (128) NOT NULL,
    [updatedBy] NVARCHAR (128) NOT NULL,
    [createdAt] INT            NOT NULL,
    [updatedAt] INT            NOT NULL,
    [jobMeta]   NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_3953bc3ec31ebb850392aee2a65] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_de29de9f2f0a4003210e38a2cb8] FOREIGN KEY ([visualId]) REFERENCES [78a38abc-56bf-4310-b918-515ffd855204].[visual] ([id])
);


GO

