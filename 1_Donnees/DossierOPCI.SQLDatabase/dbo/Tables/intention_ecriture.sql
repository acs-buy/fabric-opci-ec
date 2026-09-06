CREATE TABLE [dbo].[intention_ecriture] (
    [id]                  INT             IDENTITY (1, 1) NOT NULL,
    [entite]              VARCHAR (20)    NOT NULL,
    [arrete]              VARCHAR (20)    NOT NULL,
    [feuille_cote]        VARCHAR (30)    NOT NULL,
    [question_id]         INT             NULL,
    [mode]                VARCHAR (12)    NOT NULL,
    [compte_num]          VARCHAR (20)    NOT NULL,
    [compte_contrepartie] VARCHAR (20)    NULL,
    [montant]             DECIMAL (19, 2) NULL,
    [sens]                VARCHAR (6)     NULL,
    [solde_cible]         DECIMAL (19, 2) NULL,
    [libelle]             NVARCHAR (200)  NOT NULL,
    [lot_id]              INT             NULL,
    [cree_par]            NVARCHAR (200)  NOT NULL,
    [cree_le]             DATETIME2 (3)   DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [pk_intention_ecriture] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_ie_mode] CHECK ([mode]='SOLDE_CIBLE' OR [mode]='PAR_LIGNE'),
    CONSTRAINT [ck_ie_par_mode] CHECK ([mode]='PAR_LIGNE' AND [montant] IS NOT NULL AND [montant]>(0) AND ([sens]='CREDIT' OR [sens]='DEBIT') AND [solde_cible] IS NULL OR [mode]='SOLDE_CIBLE' AND [solde_cible] IS NOT NULL AND [montant] IS NULL AND [sens] IS NULL AND [compte_contrepartie] IS NOT NULL),
    CONSTRAINT [fk_ie_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_ie_compte] FOREIGN KEY ([compte_num]) REFERENCES [dbo].[ref_compte] ([compte]),
    CONSTRAINT [fk_ie_contrepartie] FOREIGN KEY ([compte_contrepartie]) REFERENCES [dbo].[ref_compte] ([compte]),
    CONSTRAINT [fk_ie_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_ie_lot] FOREIGN KEY ([lot_id]) REFERENCES [dbo].[lot_ecritures] ([id])
);


GO

