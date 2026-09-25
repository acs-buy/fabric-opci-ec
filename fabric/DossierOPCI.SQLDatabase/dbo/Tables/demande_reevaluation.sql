CREATE TABLE [dbo].[demande_reevaluation] (
    [id]             INT             IDENTITY (1, 1) NOT NULL,
    [entite]         VARCHAR (20)    NOT NULL,
    [arrete]         VARCHAR (20)    NOT NULL,
    [etat]           VARCHAR (12)    DEFAULT ('EN_ATTENTE') NOT NULL,
    [posee_par]      NVARCHAR (200)  NOT NULL,
    [posee_le]       DATETIME2 (3)   DEFAULT (sysutcdatetime()) NOT NULL,
    [motif_demande]  NVARCHAR (600)  NULL,
    [lot_id]         INT             NULL,
    [compte_rendu]   NVARCHAR (2000) NULL,
    [actifs_traites] INT             NULL,
    [actifs_bloques] INT             NULL,
    [servie_le]      DATETIME2 (3)   NULL,
    [servie_par]     NVARCHAR (200)  NULL,
    CONSTRAINT [pk_demande_reevaluation] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_demande_etat] CHECK ([etat]='ANNULEE' OR [etat]='REFUSEE' OR [etat]='FAITE' OR [etat]='EN_ATTENTE'),
    CONSTRAINT [ck_demande_lot_si_faite] CHECK ([etat]='FAITE' AND [lot_id] IS NOT NULL OR [etat]<>'FAITE' AND [lot_id] IS NULL),
    CONSTRAINT [ck_demande_servie] CHECK ([etat]='EN_ATTENTE' OR [compte_rendu] IS NOT NULL AND [servie_le] IS NOT NULL AND [servie_par] IS NOT NULL),
    CONSTRAINT [fk_demande_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_demande_lot] FOREIGN KEY ([lot_id]) REFERENCES [dbo].[lot_ecritures] ([id])
);


GO

CREATE NONCLUSTERED INDEX [ix_demande_arrete]
    ON [dbo].[demande_reevaluation]([entite] ASC, [arrete] ASC, [etat] ASC);


GO

CREATE UNIQUE NONCLUSTERED INDEX [uq_demande_en_attente]
    ON [dbo].[demande_reevaluation]([entite] ASC, [arrete] ASC) WHERE ([etat]='EN_ATTENTE');


GO

