CREATE TABLE [14cd3243-21c1-488b-a192-0760eaf16a68].[powertable_attachment] (
    [id]               INT            IDENTITY (1, 1) NOT NULL,
    [sourceId]         INT            NOT NULL,
    [columnName]       VARCHAR (255)  NOT NULL,
    [rowId]            VARCHAR (512)  NOT NULL,
    [rowMeta]          NVARCHAR (MAX) NULL,
    [fileName]         VARCHAR (255)  NOT NULL,
    [originalFileName] VARCHAR (255)  NOT NULL,
    [fileSize]         INT            NOT NULL,
    [mimeType]         VARCHAR (100)  NOT NULL,
    [fileExtension]    VARCHAR (10)   NOT NULL,
    [status]           INT            CONSTRAINT [DF_51ae28d8eab1e0d34e7144eba86] DEFAULT ((10)) NOT NULL,
    [createdAt]        INT            NOT NULL,
    [updatedAt]        INT            NOT NULL,
    [createdBy]        NVARCHAR (128) NOT NULL,
    [updatedBy]        NVARCHAR (128) NOT NULL,
    [storageRowId]     VARCHAR (512)  NULL,
    CONSTRAINT [PK_a57e6509e53e6c853ac46a40662] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_2bd05b1cc85a67483bedbced9c3] FOREIGN KEY ([sourceId]) REFERENCES [14cd3243-21c1-488b-a192-0760eaf16a68].[powertable_source] ([id])
);


GO

