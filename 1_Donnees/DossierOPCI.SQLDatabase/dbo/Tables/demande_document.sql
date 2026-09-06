CREATE TABLE [dbo].[demande_document] (
    [id]            INT             IDENTITY (1, 1) NOT NULL,
    [entite]        VARCHAR (20)    NOT NULL,
    [arrete]        VARCHAR (20)    NOT NULL,
    [livrable]      VARCHAR (20)    NOT NULL,
    [version]       INT             NOT NULL,
    [demande_par]   NVARCHAR (400)  NOT NULL,
    [demande_le]    DATETIME2 (3)   CONSTRAINT [df_demdoc_le] DEFAULT (sysutcdatetime()) NOT NULL,
    [etat]          VARCHAR (12)    NOT NULL,
    [chemin_coffre] NVARCHAR (800)  NULL,
    [produit_le]    DATETIME2 (3)   NULL,
    [taille_octets] INT             NULL,
    [motif_refus]   NVARCHAR (2000) NULL,
    CONSTRAINT [pk_demdoc] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_demdoc_etat] CHECK ([etat]='PRODUITE' OR [etat]='REFUSEE' OR [etat]='DEMANDEE'),
    CONSTRAINT [ck_demdoc_produite] CHECK ([etat]<>'PRODUITE' OR [chemin_coffre] IS NOT NULL AND [produit_le] IS NOT NULL),
    CONSTRAINT [ck_demdoc_refus] CHECK ([etat]<>'REFUSEE' OR [motif_refus] IS NOT NULL),
    CONSTRAINT [fk_demdoc_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_demdoc_livrable] FOREIGN KEY ([livrable]) REFERENCES [dbo].[ref_livrable] ([code]),
    CONSTRAINT [uq_demdoc] UNIQUE NONCLUSTERED ([entite] ASC, [arrete] ASC, [livrable] ASC, [version] ASC)
);


GO

CREATE NONCLUSTERED INDEX [ix_demande_document]
    ON [dbo].[demande_document]([entite] ASC, [arrete] ASC, [livrable] ASC, [version] DESC);


GO

