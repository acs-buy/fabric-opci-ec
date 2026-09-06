CREATE TABLE [dbo].[synthese_proposee] (
    [id]                    INT             IDENTITY (1, 1) NOT NULL,
    [entite]                VARCHAR (20)    NOT NULL,
    [arrete]                VARCHAR (20)    NOT NULL,
    [actif_net_rationalise] DECIMAL (19, 2) NOT NULL,
    [actif_net_calcule]     DECIMAL (19, 2) NOT NULL,
    [ecart]                 DECIMAL (19, 2) NOT NULL,
    [valeur_liquidative]    DECIMAL (19, 4) NULL,
    [propose_par]           NVARCHAR (400)  NOT NULL,
    [propose_le]            DATETIME2 (3)   NOT NULL,
    [perime_le]             DATETIME2 (3)   NULL,
    [perime_motif]          NVARCHAR (400)  NULL,
    [message_ecran]         NVARCHAR (2000) NULL,
    [message_ecran_le]      DATETIME2 (3)   NULL,
    [message_ecran_pour]    NVARCHAR (200)  NULL,
    CONSTRAINT [pk_synthese_proposee] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_synthese_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete])
);


GO

CREATE NONCLUSTERED INDEX [ix_synthese_proposee]
    ON [dbo].[synthese_proposee]([entite] ASC, [arrete] ASC, [perime_le] ASC);


GO

