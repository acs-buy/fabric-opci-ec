CREATE TABLE [dbo].[cours_titre] (
    [id]         INT             IDENTITY (1, 1) NOT NULL,
    [entite]     VARCHAR (20)    NOT NULL,
    [arrete]     VARCHAR (20)    NOT NULL,
    [code_actif] VARCHAR (20)    NOT NULL,
    [compte]     VARCHAR (20)    NOT NULL,
    [quantite]   DECIMAL (19, 4) NOT NULL,
    [cours]      DECIMAL (19, 4) NOT NULL,
    [source]     NVARCHAR (200)  NOT NULL,
    [saisi_par]  NVARCHAR (200)  NOT NULL,
    [saisi_le]   DATETIME2 (3)   DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [pk_cours_titre] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_ct_compte_admis] CHECK ([compte]='258' OR [compte]='256'),
    CONSTRAINT [ck_ct_cours] CHECK ([cours]>=(0)),
    CONSTRAINT [ck_ct_quantite] CHECK ([quantite]>(0)),
    CONSTRAINT [fk_ct_actif] FOREIGN KEY ([code_actif]) REFERENCES [dbo].[actif] ([code]),
    CONSTRAINT [fk_ct_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_ct_compte] FOREIGN KEY ([compte]) REFERENCES [dbo].[ref_compte] ([compte]),
    CONSTRAINT [uq_cours_titre] UNIQUE NONCLUSTERED ([entite] ASC, [arrete] ASC, [code_actif] ASC)
);


GO

