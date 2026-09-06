CREATE TABLE [d3b32f45-75c5-41e7-b200-fb72b5532f9e].[comment] (
    [id]                INT             IDENTITY (1, 1) NOT NULL,
    [comment]           NVARCHAR (MAX)  NULL,
    [parentCommentId]   INT             NULL,
    [visualId]          INT             NOT NULL,
    [childCount]        INT             CONSTRAINT [DF_1b8b61b6cfd14938d5571c9d52f] DEFAULT ((0)) NULL,
    [commentMeta]       NVARCHAR (MAX)  NULL,
    [filterProperties]  NVARCHAR (MAX)  NULL,
    [rowId]             NVARCHAR (2048) NULL,
    [columnId]          NVARCHAR (2048) NULL,
    [filterContextHash] NVARCHAR (256)  NULL,
    [priority]          INT             NULL,
    [important]         INT             CONSTRAINT [DF_155ee8ab70ae98873768f0a5877] DEFAULT ((20)) NULL,
    [dimensionHash]     VARCHAR (32)    NULL,
    [scenarioGuid]      NVARCHAR (255)  NULL,
    [measureGuid]       NVARCHAR (255)  NULL,
    [threadStatus]      INT             NULL,
    [threadAssignee]    NVARCHAR (512)  NULL,
    [status]            INT             CONSTRAINT [DF_c3c2abe750c76c7c8e305f71f21] DEFAULT ((10)) NOT NULL,
    [createdBy]         NVARCHAR (128)  NOT NULL,
    [createdByUPN]      NVARCHAR (320)  NOT NULL,
    [updatedBy]         NVARCHAR (128)  NOT NULL,
    [createdAt]         INT             NOT NULL,
    [updatedAt]         INT             NOT NULL,
    CONSTRAINT [PK_0b0e4bbc8415ec426f87f3a88e2] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_c17116b9b990ba6990fd8b139b7] FOREIGN KEY ([visualId]) REFERENCES [d3b32f45-75c5-41e7-b200-fb72b5532f9e].[visual] ([id]) ON DELETE CASCADE
);


GO

