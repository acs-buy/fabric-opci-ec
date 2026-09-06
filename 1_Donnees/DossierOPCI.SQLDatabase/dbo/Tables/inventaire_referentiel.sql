CREATE TABLE [dbo].[inventaire_referentiel] (
    [table_nom]             VARCHAR (120) NOT NULL,
    [lignes]                INT           NOT NULL,
    [lignes_modifiees]      INT           NOT NULL,
    [derniere_modification] DATETIME2 (3) NULL,
    [releve_le]             DATETIME2 (3) NOT NULL,
    CONSTRAINT [pk_inventaire_referentiel] PRIMARY KEY CLUSTERED ([table_nom] ASC),
    CONSTRAINT [fk_inv_referentiel] FOREIGN KEY ([table_nom]) REFERENCES [dbo].[ref_referentiel] ([table_nom])
);


GO

