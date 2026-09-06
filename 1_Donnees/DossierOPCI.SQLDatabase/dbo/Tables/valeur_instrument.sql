CREATE TABLE [dbo].[valeur_instrument] (
    [id]               INT             IDENTITY (1, 1) NOT NULL,
    [entite]           VARCHAR (20)    NOT NULL,
    [arrete]           VARCHAR (20)    NOT NULL,
    [code_actif]       VARCHAR (20)    NOT NULL,
    [compte]           VARCHAR (20)    NOT NULL,
    [valeur_comptable] DECIMAL (19, 2) NOT NULL,
    [valeur_actuelle]  DECIMAL (19, 2) NOT NULL,
    [source]           NVARCHAR (200)  NOT NULL,
    [saisi_par]        NVARCHAR (200)  NOT NULL,
    [saisi_le]         DATETIME2 (3)   DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [pk_valeur_instrument] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_vi_classe_3] CHECK (left([compte],(1))='3'),
    CONSTRAINT [fk_vi_actif] FOREIGN KEY ([code_actif]) REFERENCES [dbo].[actif] ([code]),
    CONSTRAINT [fk_vi_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_vi_compte] FOREIGN KEY ([compte]) REFERENCES [dbo].[ref_compte] ([compte]),
    CONSTRAINT [uq_valeur_instrument] UNIQUE NONCLUSTERED ([entite] ASC, [arrete] ASC, [code_actif] ASC)
);


GO

