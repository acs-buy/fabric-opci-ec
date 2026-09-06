CREATE TABLE [f421652a-1f51-49cc-965b-e8a69233e76d].[data_input_column] (
    [id]                      INT            IDENTITY (1, 1) NOT NULL,
    [visualId]                INT            NOT NULL,
    [measureGuid]             VARCHAR (255)  NOT NULL,
    [dataInputType]           INT            NOT NULL,
    [name]                    VARCHAR (255)  NOT NULL,
    [description]             VARCHAR (2048) NULL,
    [columnMeta]              NVARCHAR (MAX) NULL,
    [boundToFilterContext]    INT            CONSTRAINT [DF_904838640d21f75be1210ff7e07] DEFAULT ((20)) NOT NULL,
    [status]                  INT            CONSTRAINT [DF_99b4b205612ae34711d224e7aea] DEFAULT ((10)) NOT NULL,
    [createdBy]               NVARCHAR (128) NOT NULL,
    [updatedBy]               NVARCHAR (128) NOT NULL,
    [createdAt]               INT            NOT NULL,
    [updatedAt]               INT            NOT NULL,
    [sidecarHydrationStatus]  INT            CONSTRAINT [DF_data_input_column_sidecarHydrationStatus] DEFAULT ((10)) NOT NULL,
    [sidecarHydrationLeaseAt] BIGINT         NULL,
    CONSTRAINT [PK_e757521d9dd64e754591afabac8] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_2f2ba9690ea788805bf78ae17a1] FOREIGN KEY ([visualId]) REFERENCES [f421652a-1f51-49cc-965b-e8a69233e76d].[visual] ([id])
);


GO

CREATE NONCLUSTERED INDEX [ix_data_input_column_hydration_cold]
    ON [f421652a-1f51-49cc-965b-e8a69233e76d].[data_input_column]([sidecarHydrationStatus] ASC) WHERE ([sidecarHydrationStatus] IN ((10), (30), (50)));


GO

