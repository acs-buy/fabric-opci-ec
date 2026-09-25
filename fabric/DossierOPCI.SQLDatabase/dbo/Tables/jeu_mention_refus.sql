CREATE TABLE [dbo].[jeu_mention_refus] (
    [id]        INT             IDENTITY (1, 1) NOT NULL,
    [table_nom] VARCHAR (128)   NOT NULL,
    [colonne]   VARCHAR (128)   NOT NULL,
    [lignes]    INT             NOT NULL,
    [message]   NVARCHAR (2000) NOT NULL,
    [refuse_le] DATETIME2 (0)   CONSTRAINT [df_jeu_mention_refus_le] DEFAULT (sysutcdatetime()) NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);


GO

