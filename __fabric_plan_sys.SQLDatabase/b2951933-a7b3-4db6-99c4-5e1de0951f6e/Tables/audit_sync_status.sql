CREATE TABLE [b2951933-a7b3-4db6-99c4-5e1de0951f6e].[audit_sync_status] (
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

