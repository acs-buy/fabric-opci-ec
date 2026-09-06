CREATE TABLE [562059f4-3c4c-407c-8a2c-864f2acbe25c].[powertable_approval_request] (
    [id]                INT            IDENTITY (1, 1) NOT NULL,
    [approvalId]        INT            NOT NULL,
    [requestGuid]       VARCHAR (255)  NOT NULL,
    [sourceJobId]       INT            NULL,
    [description]       VARCHAR (255)  NULL,
    [priority]          INT            NULL,
    [duedate]           INT            NULL,
    [filterId]          INT            NOT NULL,
    [meta]              NVARCHAR (MAX) NOT NULL,
    [parentRequestGuid] VARCHAR (255)  NULL,
    [approvalLevelId]   INT            NOT NULL,
    [status]            INT            CONSTRAINT [DF_769f9827dde04b5eb7098e0b9fe] DEFAULT ((10)) NOT NULL,
    [createdBy]         NVARCHAR (128) NOT NULL,
    [updatedBy]         NVARCHAR (128) NOT NULL,
    [createdAt]         INT            NOT NULL,
    [updatedAt]         INT            NOT NULL,
    CONSTRAINT [PK_6f6c76ad1583078e4b6cc8dcd94] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_0970d533cb11ac0ebfc883d62ad] FOREIGN KEY ([approvalId]) REFERENCES [562059f4-3c4c-407c-8a2c-864f2acbe25c].[powertable_approval] ([id]),
    CONSTRAINT [FK_2bcabc9115b6cee7fb17da72c66] FOREIGN KEY ([filterId]) REFERENCES [562059f4-3c4c-407c-8a2c-864f2acbe25c].[powertable_approval_filter] ([id]),
    CONSTRAINT [FK_b7844c76936a6d26db24baece5a] FOREIGN KEY ([approvalLevelId]) REFERENCES [562059f4-3c4c-407c-8a2c-864f2acbe25c].[powertable_approval_level] ([id])
);


GO

