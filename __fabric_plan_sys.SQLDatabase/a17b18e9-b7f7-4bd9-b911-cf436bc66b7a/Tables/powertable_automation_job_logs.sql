CREATE TABLE [a17b18e9-b7f7-4bd9-b911-cf436bc66b7a].[powertable_automation_job_logs] (
    [id]                  INT            IDENTITY (1, 1) NOT NULL,
    [automationJobId]     INT            NOT NULL,
    [eventType]           INT            NOT NULL,
    [errorMsg]            NVARCHAR (MAX) NULL,
    [parameters]          NVARCHAR (MAX) NULL,
    [parentEventId]       INT            NULL,
    [subEventType]        INT            NULL,
    [storageType]         INT            CONSTRAINT [DF_c9c02d08c59722d8adba5e3c82c] DEFAULT ((1)) NULL,
    [resultPath]          NVARCHAR (255) NULL,
    [automationEventUUID] VARCHAR (255)  NULL,
    [meta]                NVARCHAR (MAX) NULL,
    [status]              INT            CONSTRAINT [DF_c93e0e7eb9cea9fc5f386351872] DEFAULT ((10)) NOT NULL,
    [createdBy]           NVARCHAR (128) NOT NULL,
    [updatedBy]           NVARCHAR (128) NOT NULL,
    [createdAt]           INT            NOT NULL,
    [updatedAt]           INT            NOT NULL,
    CONSTRAINT [PK_902819316160290e11f7764e7cc] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_169466e74c029e477bef5389d61] FOREIGN KEY ([automationJobId]) REFERENCES [a17b18e9-b7f7-4bd9-b911-cf436bc66b7a].[powertable_automation_jobs] ([id])
);


GO

