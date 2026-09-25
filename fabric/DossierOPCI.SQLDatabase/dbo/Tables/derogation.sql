CREATE TABLE [dbo].[derogation] (
    [id]                 INT             IDENTITY (1, 1) NOT NULL,
    [entite]             VARCHAR (20)    NOT NULL,
    [arrete]             VARCHAR (20)    NOT NULL,
    [cote]               VARCHAR (30)    NULL,
    [motif]              NVARCHAR (400)  NOT NULL,
    [accordee_par]       NVARCHAR (200)  NOT NULL,
    [accordee_le]        DATETIME2 (3)   DEFAULT (sysutcdatetime()) NOT NULL,
    [levee_par]          NVARCHAR (200)  NULL,
    [levee_le]           DATETIME2 (3)   NULL,
    [message_ecran]      NVARCHAR (2000) NULL,
    [message_ecran_le]   DATETIME2 (3)   NULL,
    [message_ecran_pour] NVARCHAR (200)  NULL,
    CONSTRAINT [pk_derogation] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_derog_levee_complete] CHECK ([levee_par] IS NULL AND [levee_le] IS NULL OR [levee_par] IS NOT NULL AND [levee_le] IS NOT NULL),
    CONSTRAINT [fk_derog_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_derog_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_derog_feuille] FOREIGN KEY ([cote]) REFERENCES [dbo].[feuille_travail] ([cote])
);


GO

