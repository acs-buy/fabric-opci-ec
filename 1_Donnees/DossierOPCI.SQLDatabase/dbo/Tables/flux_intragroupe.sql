CREATE TABLE [dbo].[flux_intragroupe] (
    [id]                INT             IDENTITY (1, 1) NOT NULL,
    [arrete]            VARCHAR (20)    NOT NULL,
    [nature]            VARCHAR (20)    NOT NULL,
    [entite_debitrice]  VARCHAR (20)    NOT NULL,
    [entite_creditrice] VARCHAR (20)    NOT NULL,
    [compte_debiteur]   VARCHAR (20)    NULL,
    [compte_crediteur]  VARCHAR (20)    NULL,
    [code_actif]        VARCHAR (30)    NULL,
    [montant]           DECIMAL (19, 2) NOT NULL,
    [source]            NVARCHAR (400)  NOT NULL,
    CONSTRAINT [pk_flux_intragroupe] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_flux_entites_distinctes] CHECK ([entite_debitrice]<>[entite_creditrice]),
    CONSTRAINT [ck_flux_nature] CHECK ([nature]='VENTE_IMMEUBLE' OR [nature]='DIVIDENDE' OR [nature]='INTERET' OR [nature]='PRET'),
    CONSTRAINT [fk_flux_creditrice] FOREIGN KEY ([entite_creditrice]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_flux_debitrice] FOREIGN KEY ([entite_debitrice]) REFERENCES [dbo].[ref_entite] ([code])
);


GO

CREATE NONCLUSTERED INDEX [ix_flux_intragroupe]
    ON [dbo].[flux_intragroupe]([arrete] ASC, [nature] ASC, [entite_debitrice] ASC, [entite_creditrice] ASC);


GO

