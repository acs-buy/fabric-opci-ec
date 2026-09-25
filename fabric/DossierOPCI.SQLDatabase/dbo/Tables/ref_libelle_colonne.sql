CREATE TABLE [dbo].[ref_libelle_colonne] (
    [vue]     VARCHAR (200) NOT NULL,
    [colonne] VARCHAR (200) NOT NULL,
    [libelle] NVARCHAR (40) NOT NULL,
    CONSTRAINT [pk_ref_libelle_colonne] PRIMARY KEY CLUSTERED ([vue] ASC, [colonne] ASC)
);


GO

