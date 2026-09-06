CREATE TABLE [dbo].[import_fec] (
    [id]              INT            IDENTITY (1, 1) NOT NULL,
    [entite]          VARCHAR (20)   NOT NULL,
    [arrete]          VARCHAR (20)   NOT NULL,
    [nom_fichier]     NVARCHAR (400) NOT NULL,
    [empreinte]       VARCHAR (64)   NULL,
    [exercice_debut]  DATE           NOT NULL,
    [exercice_fin]    DATE           NOT NULL,
    [lignes_lues]     INT            DEFAULT ((0)) NOT NULL,
    [lignes_rejetees] INT            DEFAULT ((0)) NOT NULL,
    [statut]          VARCHAR (20)   DEFAULT ('EN_COURS') NOT NULL,
    [importe_par]     NVARCHAR (200) NOT NULL,
    [importe_le]      DATETIME2 (3)  DEFAULT (sysutcdatetime()) NOT NULL,
    [format]          VARCHAR (10)   NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_import_exercice_ordonne] CHECK ([exercice_debut]<=[exercice_fin]),
    CONSTRAINT [ck_import_format] CHECK ([format]='BALANCE' OR [format]='FEC'),
    CONSTRAINT [ck_import_statut] CHECK ([statut]='CHARGE' OR [statut]='REJETE' OR [statut]='EN_COURS'),
    CONSTRAINT [fk_import_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_import_fec_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code])
);


GO

