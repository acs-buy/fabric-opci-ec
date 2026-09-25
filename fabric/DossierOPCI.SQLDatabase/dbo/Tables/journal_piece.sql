CREATE TABLE [dbo].[journal_piece] (
    [id]          INT            IDENTITY (1, 1) NOT NULL,
    [piece_id]    INT            NOT NULL,
    [nom_fichier] NVARCHAR (400) NOT NULL,
    [entite]      VARCHAR (20)   NOT NULL,
    [question]    VARCHAR (20)   NULL,
    [arrete]      VARCHAR (20)   NULL,
    [action]      VARCHAR (12)   NOT NULL,
    [motif]       NVARCHAR (800) NOT NULL,
    [fait_par]    NVARCHAR (400) NOT NULL,
    [fait_le]     DATETIME2 (0)  CONSTRAINT [df_journal_piece_le] DEFAULT (sysutcdatetime()) NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_journal_piece_action] CHECK ([action]='RETRAIT')
);


GO

