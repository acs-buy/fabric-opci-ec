CREATE TABLE [dbo].[ref_libelle_valeur] (
    [table_nom] VARCHAR (120) NOT NULL,
    [colonne]   VARCHAR (128) NOT NULL,
    [valeur]    NVARCHAR (30) NOT NULL,
    [libelle]   NVARCHAR (60) NOT NULL,
    CONSTRAINT [pk_ref_libelle_valeur] PRIMARY KEY CLUSTERED ([table_nom] ASC, [colonne] ASC, [valeur] ASC),
    CONSTRAINT [uq_ref_libelle_valeur_libelle] UNIQUE NONCLUSTERED ([table_nom] ASC, [colonne] ASC, [libelle] ASC)
);


GO

