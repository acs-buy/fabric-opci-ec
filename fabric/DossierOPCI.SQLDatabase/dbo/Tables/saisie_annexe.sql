CREATE TABLE [dbo].[saisie_annexe] (
    [id]        INT             IDENTITY (1, 1) NOT NULL,
    [entite]    VARCHAR (20)    NOT NULL,
    [arrete]    VARCHAR (20)    NOT NULL,
    [article]   VARCHAR (10)    NOT NULL,
    [ligne]     NVARCHAR (300)  NOT NULL,
    [colonne]   NVARCHAR (120)  NOT NULL,
    [valeur]    NVARCHAR (2000) NULL,
    [montant]   DECIMAL (19, 2) NULL,
    [saisi_par] NVARCHAR (400)  NOT NULL,
    [saisi_le]  DATETIME2 (3)   NOT NULL,
    [motif]     NVARCHAR (800)  NULL,
    [motif_par] NVARCHAR (400)  NULL,
    [motif_le]  DATETIME2 (3)   NULL,
    CONSTRAINT [pk_saisie_annexe] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_saisie_annexe_motif] CHECK ([motif] IS NULL OR [motif_par] IS NOT NULL AND [motif_le] IS NOT NULL),
    CONSTRAINT [ck_saisie_annexe_valeur] CHECK ([valeur] IS NOT NULL AND [montant] IS NULL OR [valeur] IS NULL AND [montant] IS NOT NULL),
    CONSTRAINT [fk_saisie_annexe_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_saisie_annexe_article] FOREIGN KEY ([article]) REFERENCES [dbo].[ref_article] ([article]),
    CONSTRAINT [uq_saisie_annexe] UNIQUE NONCLUSTERED ([entite] ASC, [arrete] ASC, [article] ASC, [ligne] ASC, [colonne] ASC)
);


GO

CREATE NONCLUSTERED INDEX [ix_saisie_annexe]
    ON [dbo].[saisie_annexe]([entite] ASC, [arrete] ASC, [article] ASC);


GO

CREATE   TRIGGER dbo.[tr_saisie_annexe_garde]
ON dbo.[saisie_annexe]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('saisie_annexe',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé ou réviseur. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

