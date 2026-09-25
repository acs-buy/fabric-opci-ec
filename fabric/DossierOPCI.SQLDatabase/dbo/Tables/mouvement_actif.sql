CREATE TABLE [dbo].[mouvement_actif] (
    [id]                  INT             IDENTITY (1, 1) NOT NULL,
    [code_actif]          VARCHAR (20)    NOT NULL,
    [entite]              VARCHAR (20)    NOT NULL,
    [arrete]              VARCHAR (20)    NOT NULL,
    [nature]              VARCHAR (14)    NOT NULL,
    [date_mouvement]      DATE            NOT NULL,
    [montant]             DECIMAL (19, 2) NOT NULL,
    [prix_cession]        DECIMAL (19, 2) NULL,
    [valeur_nette_sortie] DECIMAL (19, 2) NULL,
    [frais]               DECIMAL (19, 2) DEFAULT ((0)) NOT NULL,
    [piece_id]            INT             NULL,
    [saisi_par]           NVARCHAR (200)  NOT NULL,
    [saisi_le]            DATETIME2 (3)   DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [pk_mouvement_actif] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_ma_cession_complete] CHECK (NOT ([nature]='SORTIE' OR [nature]='CESSION') OR [prix_cession] IS NOT NULL AND [valeur_nette_sortie] IS NOT NULL),
    CONSTRAINT [ck_ma_entree_sans_cession] CHECK (NOT ([nature]='TRAVAUX' OR [nature]='ACQUISITION') OR [prix_cession] IS NULL AND [valeur_nette_sortie] IS NULL),
    CONSTRAINT [ck_ma_montant] CHECK ([montant]>(0)),
    CONSTRAINT [ck_ma_nature] CHECK ([nature]='SORTIE' OR [nature]='CESSION' OR [nature]='TRAVAUX' OR [nature]='ACQUISITION'),
    CONSTRAINT [fk_ma_actif] FOREIGN KEY ([code_actif]) REFERENCES [dbo].[actif] ([code]),
    CONSTRAINT [fk_ma_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_ma_piece] FOREIGN KEY ([piece_id]) REFERENCES [dbo].[piece] ([id])
);


GO

CREATE NONCLUSTERED INDEX [ix_mouvement_actif_arrete]
    ON [dbo].[mouvement_actif]([entite] ASC, [arrete] ASC);


GO

