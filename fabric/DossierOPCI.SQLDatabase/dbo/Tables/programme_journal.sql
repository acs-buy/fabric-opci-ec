CREATE TABLE [dbo].[programme_journal] (
    [id]           INT            IDENTITY (1, 1) NOT NULL,
    [programme_id] INT            NOT NULL,
    [question_id]  INT            NULL,
    [geste]        VARCHAR (8)    NOT NULL,
    [detail]       NVARCHAR (200) NULL,
    [par]          NVARCHAR (400) NOT NULL,
    [le]           DATETIME2 (3)  DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [pk_programme_journal] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_pj_geste] CHECK ([geste]='RETRAIT' OR [geste]='AJOUT' OR [geste]='CHOIX'),
    CONSTRAINT [fk_pj_programme] FOREIGN KEY ([programme_id]) REFERENCES [dbo].[programme_travail] ([id])
);


GO

