CREATE TABLE [dbo].[stg_balance] (
    [id]               INT             IDENTITY (1, 1) NOT NULL,
    [reference_import] VARCHAR (100)   NOT NULL,
    [import_id]        INT             NULL,
    [numero_ligne]     INT             NOT NULL,
    [entite]           VARCHAR (20)    NOT NULL,
    [compte_entite]    VARCHAR (20)    NOT NULL,
    [libelle_entite]   NVARCHAR (400)  NULL,
    [solde_debiteur]   DECIMAL (19, 2) DEFAULT ((0)) NOT NULL,
    [solde_crediteur]  DECIMAL (19, 2) DEFAULT ((0)) NOT NULL,
    [recevable]        INT             DEFAULT ((1)) NOT NULL,
    [motif_rejet]      NVARCHAR (800)  NULL,
    [source_format]    NVARCHAR (200)  DEFAULT (N'SIMULE : 4 colonnes de la pratique, aucun texte ne prescrit un format de balance') NOT NULL,
    CONSTRAINT [pk_stg_balance] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_stg_balance_bit] CHECK ([recevable]=(1) OR [recevable]=(0)),
    CONSTRAINT [ck_stg_balance_motif] CHECK ([recevable]=(1) OR [motif_rejet] IS NOT NULL),
    CONSTRAINT [ck_stg_balance_soldes] CHECK ([solde_debiteur]>=(0) AND [solde_crediteur]>=(0)),
    CONSTRAINT [ck_stg_balance_un_seul_sens] CHECK ([solde_debiteur]=(0) OR [solde_crediteur]=(0)),
    CONSTRAINT [fk_stg_balance_import] FOREIGN KEY ([import_id]) REFERENCES [dbo].[import_fec] ([id]),
    CONSTRAINT [uq_stg_balance] UNIQUE NONCLUSTERED ([reference_import] ASC, [numero_ligne] ASC)
);


GO

CREATE NONCLUSTERED INDEX [ix_stg_balance_ref]
    ON [dbo].[stg_balance]([reference_import] ASC);


GO

