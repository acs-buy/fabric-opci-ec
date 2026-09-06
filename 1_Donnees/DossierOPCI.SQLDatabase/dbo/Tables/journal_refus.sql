CREATE TABLE [dbo].[journal_refus] (
    [id]                 INT             IDENTITY (1, 1) NOT NULL,
    [procedure_nom]      VARCHAR (60)    NOT NULL,
    [entite]             VARCHAR (20)    NULL,
    [arrete]             VARCHAR (20)    NULL,
    [cote]               VARCHAR (30)    NULL,
    [message]            NVARCHAR (2000) NOT NULL,
    [refuse_pour]        NVARCHAR (200)  NOT NULL,
    [refuse_le]          DATETIME2 (3)   DEFAULT (sysutcdatetime()) NOT NULL,
    [question_reference] VARCHAR (20)    NULL,
    [geste]              NVARCHAR (400)  NULL,
    CONSTRAINT [pk_journal_refus] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO

