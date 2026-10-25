CREATE TABLE [dbo].[ref_ratio_memoire_article] (
    [code]    VARCHAR (30) NOT NULL,
    [article] VARCHAR (10) NOT NULL,
    [colonne] VARCHAR (40) NOT NULL,
    CONSTRAINT [pk_ref_ratio_memoire_article] PRIMARY KEY CLUSTERED ([code] ASC, [article] ASC, [colonne] ASC),
    CONSTRAINT [ck_rrma_colonne] CHECK ([colonne]='fondement_professionnel' OR [colonne]='fondement_grand_public' OR [colonne]='dates_respect_professionnel' OR [colonne]='dates_respect' OR [colonne]='article_calcul'),
    CONSTRAINT [fk_rrma_article] FOREIGN KEY ([article]) REFERENCES [dbo].[ref_article] ([article]),
    CONSTRAINT [fk_rrma_ratio_memoire] FOREIGN KEY ([code]) REFERENCES [dbo].[ref_ratio_memoire] ([code])
);


GO

