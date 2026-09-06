CREATE TABLE [b564a4cf-ac28-4e46-9a92-7e31acfe55e4].[visual] (
    [id]                   INT              IDENTITY (1, 1) NOT NULL,
    [visualMeta]           NVARCHAR (MAX)   NULL,
    [filterContextMapping] NVARCHAR (MAX)   NULL,
    [status]               INT              CONSTRAINT [DF_5a2f86a2e2fe042955704a0fc3f] DEFAULT ((10)) NOT NULL,
    [createdBy]            NVARCHAR (128)   NOT NULL,
    [updatedBy]            NVARCHAR (128)   NOT NULL,
    [createdAt]            INT              NOT NULL,
    [updatedAt]            INT              NOT NULL,
    [recordGuid]           UNIQUEIDENTIFIER CONSTRAINT [DF_visual_recordGuid] DEFAULT (newsequentialid()) NOT NULL,
    CONSTRAINT [PK_af8132b2ef744e2703ea70799cc] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_visual_recordGuid]
    ON [b564a4cf-ac28-4e46-9a92-7e31acfe55e4].[visual]([recordGuid] ASC);


GO

