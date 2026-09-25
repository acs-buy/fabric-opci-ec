CREATE TABLE [dbo].[releve_coffre] (
    [id]                INT            IDENTITY (1, 1) NOT NULL,
    [passage]           INT            NOT NULL,
    [chemin_racine]     NVARCHAR (800) NOT NULL,
    [debute_le]         DATETIME2 (3)  NOT NULL,
    [acheve_le]         DATETIME2 (3)  NULL,
    [fichiers_lus]      INT            DEFAULT ((0)) NOT NULL,
    [fichiers_inscrits] INT            DEFAULT ((0)) NOT NULL,
    [doublons_refuses]  INT            DEFAULT ((0)) NOT NULL,
    [erreurs]           INT            DEFAULT ((0)) NOT NULL,
    [motif_arret]       NVARCHAR (600) NULL,
    [releve_par]        NVARCHAR (200) NOT NULL,
    CONSTRAINT [pk_releve_coffre] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_releve_coherent] CHECK ((([fichiers_inscrits]+[doublons_refuses])+[erreurs])<=[fichiers_lus]),
    CONSTRAINT [ck_releve_comptes] CHECK ([fichiers_lus]>=(0) AND [fichiers_inscrits]>=(0) AND [doublons_refuses]>=(0) AND [erreurs]>=(0)),
    CONSTRAINT [ck_releve_horodatage] CHECK ([acheve_le] IS NULL OR [acheve_le]>=[debute_le]),
    CONSTRAINT [uq_releve_passage] UNIQUE NONCLUSTERED ([passage] ASC)
);


GO

