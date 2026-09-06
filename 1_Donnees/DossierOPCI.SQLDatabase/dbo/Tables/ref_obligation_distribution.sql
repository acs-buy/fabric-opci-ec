CREATE TABLE [dbo].[ref_obligation_distribution] (
    [categorie]                VARCHAR (30)    NOT NULL,
    [libelle]                  NVARCHAR (300)  NOT NULL,
    [taux]                     DECIMAL (9, 4)  NOT NULL,
    [abattement]               DECIMAL (9, 4)  NULL,
    [article]                  NVARCHAR (60)   NOT NULL,
    [citation]                 NVARCHAR (1200) NOT NULL,
    [lu_le]                    DATE            NOT NULL,
    [exercice_de_rattachement] VARCHAR (20)    NOT NULL,
    [ordre]                    INT             NOT NULL,
    [modifie_par]              NVARCHAR (400)  NULL,
    [modifie_le]               DATETIME2 (3)   NULL,
    CONSTRAINT [pk_ref_obligation_distribution] PRIMARY KEY CLUSTERED ([categorie] ASC),
    CONSTRAINT [ck_obligation_rattachement] CHECK ([exercice_de_rattachement]='EXERCICE_SUIVANT' OR [exercice_de_rattachement]='EXERCICE'),
    CONSTRAINT [uq_ref_obligation_ordre] UNIQUE NONCLUSTERED ([ordre] ASC)
);


GO

CREATE   TRIGGER dbo.[tr_ref_obligation_distribution_garde]
ON dbo.[ref_obligation_distribution]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_obligation_distribution',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_obligation_distribution_horodatage]
ON dbo.[ref_obligation_distribution]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    -- Un semis ne marque pas la ligne comme modifiee : sans quoi son
    -- premier passage interdirait a tous les suivants de corriger leurs
    -- propres lignes.
    IF CAST(ISNULL(SESSION_CONTEXT(N'semis'), 0) AS INT) = 1 RETURN;
    IF NOT EXISTS (SELECT 1 FROM inserted) RETURN;
    UPDATE t SET modifie_par = SUSER_SNAME(), modifie_le = SYSUTCDATETIME()
    FROM dbo.[ref_obligation_distribution] t
    JOIN inserted i ON t.[categorie] = i.[categorie];
END;

GO

