CREATE TABLE [dbo].[export_dossier] (
    [id]             INT             IDENTITY (1, 1) NOT NULL,
    [entite]         VARCHAR (20)    NOT NULL,
    [arrete]         VARCHAR (20)    NOT NULL,
    [fichier]        NVARCHAR (400)  NOT NULL,
    [statut]         VARCHAR (12)    NOT NULL,
    [web_url]        NVARCHAR (800)  NULL,
    [chemin_onelake] NVARCHAR (800)  NULL,
    [taille]         INT             NULL,
    [message]        NVARCHAR (2000) NULL,
    [depose_par]     NVARCHAR (400)  NOT NULL,
    [depose_le]      DATETIME2 (3)   CONSTRAINT [df_export_le] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [pk_export_dossier] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_export_statut] CHECK ([statut]='ERREUR' OR [statut]='FAIT'),
    CONSTRAINT [fk_export_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code])
);


GO

