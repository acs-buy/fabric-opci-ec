CREATE TABLE [a17b18e9-b7f7-4bd9-b911-cf436bc66b7a].[powertable_source_jobs] (
    [id]        INT            IDENTITY (1, 1) NOT NULL,
    [jobId]     VARCHAR (255)  NOT NULL,
    [sourceId]  INT            NOT NULL,
    [jobType]   INT            NOT NULL,
    [actions]   NVARCHAR (255) NULL,
    [startTime] INT            NULL,
    [endTime]   INT            NULL,
    [errorCode] NVARCHAR (MAX) NULL,
    [errorMsg]  NVARCHAR (MAX) NULL,
    [jobMeta]   NVARCHAR (MAX) NULL,
    [result]    NVARCHAR (MAX) NULL,
    [status]    INT            CONSTRAINT [DF_5696cd0fa13b0de5858115ab215] DEFAULT ((10)) NOT NULL,
    [createdBy] NVARCHAR (128) NOT NULL,
    [updatedBy] NVARCHAR (128) NOT NULL,
    [createdAt] INT            NOT NULL,
    [updatedAt] INT            NOT NULL,
    CONSTRAINT [PK_a59cd1517ee3a08798be82ef309] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_7a02b8db87352804f12e6c9bf82] FOREIGN KEY ([sourceId]) REFERENCES [a17b18e9-b7f7-4bd9-b911-cf436bc66b7a].[powertable_source] ([id])
);


GO

