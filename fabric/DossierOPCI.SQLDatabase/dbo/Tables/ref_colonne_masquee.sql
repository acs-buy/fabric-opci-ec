CREATE TABLE [dbo].[ref_colonne_masquee] (
    [vue]     VARCHAR (200) NOT NULL,
    [colonne] VARCHAR (200) NOT NULL,
    [motif]   VARCHAR (10)  NOT NULL,
    CONSTRAINT [pk_ref_colonne_masquee] PRIMARY KEY CLUSTERED ([vue] ASC, [colonne] ASC),
    CONSTRAINT [ck_ref_colonne_motif] CHECK ([motif]='contexte' OR [motif]='detail' OR [motif]='double' OR [motif]='cle')
);


GO

