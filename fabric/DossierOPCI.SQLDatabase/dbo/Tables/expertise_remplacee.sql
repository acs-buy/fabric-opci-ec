CREATE TABLE [dbo].[expertise_remplacee] (
    [id]              INT             IDENTITY (1, 1) NOT NULL,
    [expertise_id]    INT             NOT NULL,
    [code_actif]      VARCHAR (20)    NOT NULL,
    [date_valeur]     DATE            NOT NULL,
    [valeur_actuelle] DECIMAL (19, 2) NOT NULL,
    [expert]          NVARCHAR (200)  NULL,
    [methode]         NVARCHAR (200)  NULL,
    [piece_id]        INT             NULL,
    [enregistre_par]  NVARCHAR (200)  NULL,
    [enregistre_le]   DATETIME2 (7)   NULL,
    [version]         INT             NULL,
    [remplacee_par]   NVARCHAR (400)  NOT NULL,
    [remplacee_le]    DATETIME2 (7)   CONSTRAINT [df_exr_remplacee_le] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [pk_expertise_remplacee] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_exr_expertise] FOREIGN KEY ([expertise_id]) REFERENCES [dbo].[expertise] ([id])
);


GO

