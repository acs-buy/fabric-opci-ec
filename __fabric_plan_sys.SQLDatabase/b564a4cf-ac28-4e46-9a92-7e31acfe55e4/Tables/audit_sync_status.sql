CREATE TABLE [b564a4cf-ac28-4e46-9a92-7e31acfe55e4].[audit_sync_status] (
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

