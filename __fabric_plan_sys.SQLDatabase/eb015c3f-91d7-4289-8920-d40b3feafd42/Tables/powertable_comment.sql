CREATE TABLE [eb015c3f-91d7-4289-8920-d40b3feafd42].[powertable_comment] (
    [id]                INT            IDENTITY (1, 1) NOT NULL,
    [sourceId]          INT            NOT NULL,
    [comment]           NVARCHAR (MAX) NOT NULL,
    [commentGuid]       VARCHAR (255)  NOT NULL,
    [parentCommentGuid] VARCHAR (255)  NULL,
    [childCount]        INT            CONSTRAINT [DF_c538d4a5f6266fedfba96e1c7ea] DEFAULT ((0)) NOT NULL,
    [commentMeta]       NVARCHAR (MAX) NULL,
    [threadStatus]      NVARCHAR (MAX) NULL,
    [threadAssignee]    NVARCHAR (MAX) NULL,
    [commentRowId]      NVARCHAR (MAX) NULL,
    [commentColumnId]   NVARCHAR (MAX) NULL,
    [approvalRequestId] INT            NULL,
    [status]            INT            CONSTRAINT [DF_a8ec8741c9f07e92e2a508b32c0] DEFAULT ((10)) NOT NULL,
    [createdBy]         NVARCHAR (128) NOT NULL,
    [updatedBy]         NVARCHAR (128) NOT NULL,
    [createdAt]         INT            NOT NULL,
    [updatedAt]         INT            NOT NULL,
    CONSTRAINT [PK_812dc32bba2652532230f2a905b] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_e923d030022f35af27a650126af] FOREIGN KEY ([sourceId]) REFERENCES [eb015c3f-91d7-4289-8920-d40b3feafd42].[powertable_source] ([id])
);


GO

