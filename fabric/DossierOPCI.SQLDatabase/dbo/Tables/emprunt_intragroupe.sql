CREATE TABLE [dbo].[emprunt_intragroupe] (
    [id]              INT             IDENTITY (1, 1) NOT NULL,
    [entite_preteuse] VARCHAR (20)    NOT NULL,
    [entite_emprunt]  VARCHAR (20)    NOT NULL,
    [reference]       VARCHAR (30)    NOT NULL,
    [objet]           VARCHAR (14)    NOT NULL,
    [code_actif]      VARCHAR (20)    NULL,
    [montant_initial] DECIMAL (19, 2) NOT NULL,
    [capital_restant] DECIMAL (19, 2) NOT NULL,
    [taux_annuel]     DECIMAL (6, 4)  NOT NULL,
    [date_versement]  DATE            NOT NULL,
    [date_echeance]   DATE            NULL,
    [subordonne]      INT             DEFAULT ((0)) NOT NULL,
    [source]          NVARCHAR (200)  NOT NULL,
    CONSTRAINT [pk_emprunt_intragroupe] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_ei_actif_si_affecte] CHECK ([objet]='TRESORERIE' OR [code_actif] IS NOT NULL),
    CONSTRAINT [ck_ei_bit] CHECK ([subordonne]=(1) OR [subordonne]=(0)),
    CONSTRAINT [ck_ei_echeance] CHECK ([date_echeance] IS NULL OR [date_echeance]>[date_versement]),
    CONSTRAINT [ck_ei_entites_distinctes] CHECK ([entite_preteuse]<>[entite_emprunt]),
    CONSTRAINT [ck_ei_montants] CHECK ([montant_initial]>(0) AND [capital_restant]>=(0) AND [capital_restant]<=[montant_initial]),
    CONSTRAINT [ck_ei_objet] CHECK ([objet]='TRESORERIE' OR [objet]='TRAVAUX' OR [objet]='ACQUISITION'),
    CONSTRAINT [ck_ei_taux] CHECK ([taux_annuel]>=(0) AND [taux_annuel]<=(20)),
    CONSTRAINT [ck_ei_tresorerie_sans_actif] CHECK ([objet]<>'TRESORERIE' OR [code_actif] IS NULL),
    CONSTRAINT [fk_ei_actif] FOREIGN KEY ([code_actif]) REFERENCES [dbo].[actif] ([code]),
    CONSTRAINT [fk_ei_emprunt] FOREIGN KEY ([entite_emprunt]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_ei_preteuse] FOREIGN KEY ([entite_preteuse]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [uq_emprunt_intragroupe] UNIQUE NONCLUSTERED ([reference] ASC)
);


GO

CREATE NONCLUSTERED INDEX [ix_ei_emprunteur]
    ON [dbo].[emprunt_intragroupe]([entite_emprunt] ASC, [entite_preteuse] ASC);


GO

