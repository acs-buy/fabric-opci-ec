CREATE TABLE [dbo].[essai_saisie_grille] (
    [id]               INT             NOT NULL,
    [libelle]          NVARCHAR (120)  NULL,
    [montant]          DECIMAL (19, 2) NULL,
    [quantite]         INT             NULL,
    [le_jour]          DATE            NULL,
    [est_coche]        BIT             NULL,
    [choix]            NVARCHAR (20)   NULL,
    [valeur_de_depart] NVARCHAR (200)  NOT NULL,
    CONSTRAINT [pk_essai_saisie_grille] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO

