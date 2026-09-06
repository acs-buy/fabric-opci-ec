CREATE TABLE [52033849-181f-483f-b67d-f35f0ed7634c].[powertable_automation] (
    [id]              INT              IDENTITY (1, 1) NOT NULL,
    [name]            VARCHAR (255)    NOT NULL,
    [sourceId]        INT              NOT NULL,
    [triggerType]     INT              NOT NULL,
    [config]          NVARCHAR (MAX)   NOT NULL,
    [configUpdatedAt] INT              NULL,
    [status]          INT              CONSTRAINT [DF_09ad5dc3ec49abe42add1e70693] DEFAULT ((10)) NOT NULL,
    [createdBy]       NVARCHAR (128)   NOT NULL,
    [updatedBy]       NVARCHAR (128)   NOT NULL,
    [createdAt]       INT              NOT NULL,
    [updatedAt]       INT              NOT NULL,
    [recordGuid]      UNIQUEIDENTIFIER CONSTRAINT [DF_powertable_automation_recordGuid] DEFAULT (newsequentialid()) NOT NULL,
    CONSTRAINT [PK_07e827ae5ed8868fafbdcbbb8a1] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_84f71feccc1ee888ab03a46330c] FOREIGN KEY ([sourceId]) REFERENCES [52033849-181f-483f-b67d-f35f0ed7634c].[powertable_source] ([id])
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_powertable_automation_recordGuid]
    ON [52033849-181f-483f-b67d-f35f0ed7634c].[powertable_automation]([recordGuid] ASC);


GO

