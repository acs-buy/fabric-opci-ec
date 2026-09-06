CREATE TABLE [78a38abc-56bf-4310-b918-515ffd855204].[powertable_audit] (
    [id]                INT            IDENTITY (1, 1) NOT NULL,
    [activityType]      INT            NOT NULL,
    [entityType]        INT            NOT NULL,
    [entityId]          INT            NOT NULL,
    [propertyName]      VARCHAR (100)  NULL,
    [propertyId]        NVARCHAR (MAX) NULL,
    [rowMeta]           NVARCHAR (MAX) NULL,
    [attribute]         VARCHAR (100)  NULL,
    [action]            VARCHAR (100)  NOT NULL,
    [oldValue]          NVARCHAR (MAX) NULL,
    [newValue]          NVARCHAR (MAX) NULL,
    [approvalRequestId] INT            NULL,
    [approverId]        NVARCHAR (128) NULL,
    [approvedAt]        INT            NULL,
    [sourceJobGuid]     VARCHAR (100)  NULL,
    [oldDisplayValue]   NVARCHAR (MAX) NULL,
    [newDisplayValue]   NVARCHAR (MAX) NULL,
    [inputSource]       INT            NULL,
    [status]            INT            CONSTRAINT [DF_a29a94fea66ff9b0bdd3e000871] DEFAULT ((10)) NOT NULL,
    [createdBy]         NVARCHAR (128) NOT NULL,
    [updatedBy]         NVARCHAR (128) NOT NULL,
    [createdAt]         INT            NOT NULL,
    [updatedAt]         INT            NOT NULL,
    CONSTRAINT [PK_99f95fcbc04c06a0766366bb4da] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [idx_status_activityType_entityId_entityType_action]
    ON [78a38abc-56bf-4310-b918-515ffd855204].[powertable_audit]([status] ASC, [activityType] ASC, [entityId] ASC, [entityType] ASC, [action] ASC);


GO

