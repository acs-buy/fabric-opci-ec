CREATE TABLE [b2951933-a7b3-4db6-99c4-5e1de0951f6e].[powertable_automation_jobs] (
    [id]            INT            IDENTITY (1, 1) NOT NULL,
    [jobId]         NVARCHAR (MAX) NOT NULL,
    [automationId]  INT            NOT NULL,
    [originalJobId] INT            NULL,
    [jobType]       INT            CONSTRAINT [DF_a88b33e25c1b9ef7b6474510f76] DEFAULT ((10)) NOT NULL,
    [jobMeta]       NVARCHAR (MAX) NOT NULL,
    [errorMsg]      NVARCHAR (MAX) NULL,
    [status]        INT            CONSTRAINT [DF_bee6b1af044169a4d923dbe60d4] DEFAULT ((10)) NOT NULL,
    [createdBy]     NVARCHAR (128) NOT NULL,
    [updatedBy]     NVARCHAR (128) NOT NULL,
    [createdAt]     INT            NOT NULL,
    [updatedAt]     INT            NOT NULL,
    CONSTRAINT [PK_d79ec94c09828b634382d095da5] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_120213f481e305767799170df45] FOREIGN KEY ([automationId]) REFERENCES [b2951933-a7b3-4db6-99c4-5e1de0951f6e].[powertable_automation] ([id]),
    CONSTRAINT [FK_e9a7c636f747619313467e2b6a2] FOREIGN KEY ([originalJobId]) REFERENCES [b2951933-a7b3-4db6-99c4-5e1de0951f6e].[powertable_automation_jobs] ([id])
);


GO

