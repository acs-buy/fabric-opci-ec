CREATE TABLE [dbo].[journal_perimetre] (
    [id]           INT            IDENTITY (1, 1) NOT NULL,
    [entite_mere]  VARCHAR (20)   NOT NULL,
    [entite_fille] VARCHAR (20)   NOT NULL,
    [action]       VARCHAR (12)   NOT NULL,
    [detail]       NVARCHAR (800) NULL,
    [fait_par]     NVARCHAR (400) NOT NULL,
    [fait_le]      DATETIME2 (0)  CONSTRAINT [df_journal_perimetre_le] DEFAULT (sysutcdatetime()) NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_journal_perimetre_action] CHECK ([action]='SUPPRESSION' OR [action]='MODIFICATION' OR [action]='AJOUT')
);


GO

