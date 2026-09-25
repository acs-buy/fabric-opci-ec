CREATE TABLE [dbo].[jeu_mention_retiree] (
    [id]           INT            IDENTITY (1, 1) NOT NULL,
    [table_nom]    VARCHAR (128)  NOT NULL,
    [colonne]      VARCHAR (128)  NOT NULL,
    [valeur_avant] NVARCHAR (400) NOT NULL,
    [valeur_apres] NVARCHAR (400) NOT NULL,
    [lignes]       INT            NOT NULL,
    [fait_par]     NVARCHAR (400) NOT NULL,
    [fait_le]      DATETIME2 (0)  CONSTRAINT [df_jeu_mention_le] DEFAULT (sysutcdatetime()) NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);


GO

