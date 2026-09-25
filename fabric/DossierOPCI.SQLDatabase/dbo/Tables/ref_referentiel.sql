CREATE TABLE [dbo].[ref_referentiel] (
    [table_nom] VARCHAR (120)  NOT NULL,
    [libelle]   NVARCHAR (160) NOT NULL,
    [ecran_lu]  NVARCHAR (200) NOT NULL,
    [qui_tient] VARCHAR (20)   NOT NULL,
    [ordre]     INT            NOT NULL,
    CONSTRAINT [pk_ref_referentiel] PRIMARY KEY CLUSTERED ([table_nom] ASC),
    CONSTRAINT [ck_ref_referentiel_tient] CHECK ([qui_tient]='BASE' OR [qui_tient]='REVISEUR' OR [qui_tient]='ASSOCIE'),
    CONSTRAINT [uq_ref_referentiel_ordre] UNIQUE NONCLUSTERED ([ordre] ASC)
);


GO

