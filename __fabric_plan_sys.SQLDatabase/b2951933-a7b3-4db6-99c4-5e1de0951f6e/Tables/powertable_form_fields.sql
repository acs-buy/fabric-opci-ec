CREATE TABLE [b2951933-a7b3-4db6-99c4-5e1de0951f6e].[powertable_form_fields] (
    [id]             INT              IDENTITY (1, 1) NOT NULL,
    [formId]         INT              NOT NULL,
    [columnConfigId] INT              NOT NULL,
    [description]    VARCHAR (255)    NOT NULL,
    [required]       INT              NOT NULL,
    [defaultValue]   NVARCHAR (MAX)   NOT NULL,
    [status]         INT              CONSTRAINT [DF_a5da4719ab217e0d8c02a22a4f7] DEFAULT ((10)) NOT NULL,
    [createdBy]      NVARCHAR (128)   NOT NULL,
    [updatedBy]      NVARCHAR (128)   NOT NULL,
    [createdAt]      INT              NOT NULL,
    [updatedAt]      INT              NOT NULL,
    [recordGuid]     UNIQUEIDENTIFIER CONSTRAINT [DF_powertable_form_fields_recordGuid] DEFAULT (newsequentialid()) NOT NULL,
    CONSTRAINT [PK_5e3f7798212c9a3750670cda06f] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_3ac84e41365aa65e78bea0d204d] FOREIGN KEY ([columnConfigId]) REFERENCES [b2951933-a7b3-4db6-99c4-5e1de0951f6e].[powertable_column_config] ([id]),
    CONSTRAINT [FK_7a435d56a08a01bf0a9cf169e52] FOREIGN KEY ([formId]) REFERENCES [b2951933-a7b3-4db6-99c4-5e1de0951f6e].[powertable_forms] ([id])
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_powertable_form_fields_recordGuid]
    ON [b2951933-a7b3-4db6-99c4-5e1de0951f6e].[powertable_form_fields]([recordGuid] ASC);


GO

