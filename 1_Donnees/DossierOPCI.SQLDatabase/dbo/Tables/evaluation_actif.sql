CREATE TABLE [dbo].[evaluation_actif] (
    [id]                 INT             IDENTITY (1, 1) NOT NULL,
    [code_actif]         VARCHAR (20)    NOT NULL,
    [entite]             VARCHAR (20)    NOT NULL,
    [arrete]             VARCHAR (20)    NOT NULL,
    [valeur_retenue]     DECIMAL (19, 2) NOT NULL,
    [source]             VARCHAR (20)    NOT NULL,
    [expertise_id]       INT             NULL,
    [motif_ecart]        NVARCHAR (600)  NULL,
    [propose_par]        NVARCHAR (200)  NOT NULL,
    [propose_le]         DATETIME2 (3)   DEFAULT (sysutcdatetime()) NOT NULL,
    [etat]               VARCHAR (10)    DEFAULT ('PROPOSE') NOT NULL,
    [vise_par]           NVARCHAR (200)  NULL,
    [vise_le]            DATETIME2 (3)   NULL,
    [motif_renvoi]       NVARCHAR (600)  NULL,
    [message_ecran]      NVARCHAR (2000) NULL,
    [message_ecran_le]   DATETIME2 (3)   NULL,
    [message_ecran_pour] NVARCHAR (200)  NULL,
    CONSTRAINT [pk_evaluation_actif] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_ev_ecart_motive] CHECK ([expertise_id] IS NULL OR [motif_ecart] IS NOT NULL OR [source]='EXPERTISE'),
    CONSTRAINT [ck_ev_etat] CHECK ([etat]='RENVOYE' OR [etat]='VISE' OR [etat]='PROPOSE'),
    CONSTRAINT [ck_ev_etat_vise] CHECK ([etat]='PROPOSE' OR [vise_par] IS NOT NULL AND [vise_le] IS NOT NULL),
    CONSTRAINT [ck_ev_expertise_nommee] CHECK ([source]<>'EXPERTISE' OR [expertise_id] IS NOT NULL),
    CONSTRAINT [ck_ev_source] CHECK ([source]='PRIX_REVIENT' OR [source]='NOMINAL' OR [source]='MODELE' OR [source]='MARCHE' OR [source]='EXPERTISE'),
    CONSTRAINT [fk_ev_actif] FOREIGN KEY ([code_actif]) REFERENCES [dbo].[actif] ([code]),
    CONSTRAINT [fk_ev_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_ev_expertise] FOREIGN KEY ([expertise_id]) REFERENCES [dbo].[expertise] ([id]),
    CONSTRAINT [uq_evaluation_actif] UNIQUE NONCLUSTERED ([code_actif] ASC, [entite] ASC, [arrete] ASC)
);


GO

CREATE NONCLUSTERED INDEX [ix_evaluation_actif_arrete]
    ON [dbo].[evaluation_actif]([entite] ASC, [arrete] ASC);


GO

