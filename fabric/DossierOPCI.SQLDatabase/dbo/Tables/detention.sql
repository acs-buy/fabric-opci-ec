CREATE TABLE [dbo].[detention] (
    [entite_mere]  VARCHAR (20)   NOT NULL,
    [entite_fille] VARCHAR (20)   NOT NULL,
    [arrete]       VARCHAR (20)   NOT NULL,
    [quote_part]   DECIMAL (9, 6) NOT NULL,
    CONSTRAINT [pk_detention] PRIMARY KEY CLUSTERED ([entite_mere] ASC, [entite_fille] ASC, [arrete] ASC),
    CONSTRAINT [ck_detention_pas_de_boucle_directe] CHECK ([entite_mere]<>[entite_fille]),
    CONSTRAINT [ck_detention_quote_part] CHECK ([quote_part]>(0) AND [quote_part]<=(1)),
    CONSTRAINT [fk_detention_arrete] FOREIGN KEY ([entite_mere], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_detention_fille] FOREIGN KEY ([entite_fille]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_detention_mere] FOREIGN KEY ([entite_mere]) REFERENCES [dbo].[ref_entite] ([code])
);


GO

