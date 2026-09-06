CREATE TABLE [31e46168-a84d-491d-9615-f018f7009712].[audit_sync_status] (
    [id]                  INT            IDENTITY (1, 1) NOT NULL,
    [visualId]            INT            NOT NULL,
    [auditType]           INT            NOT NULL,
    [syncStatus]          NVARCHAR (50)  NULL,
    [lastSyncSucceededAt] INT            NULL,
    [attemptedAt]         INT            NULL,
    [status]              INT            DEFAULT ((10)) NOT NULL,
    [createdAt]           INT            NOT NULL,
    [createdBy]           NVARCHAR (255) NOT NULL,
    [updatedAt]           INT            NOT NULL,
    [updatedBy]           NVARCHAR (255) NOT NULL,
    [syncStatusCode]      INT            NULL,
    CONSTRAINT [PK_audit_sync_status] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [UQ_audit_sync_status_visual_type] UNIQUE NONCLUSTERED ([visualId] ASC, [auditType] ASC)
);


GO

