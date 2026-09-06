CREATE TABLE [dbo].[ref_tableau_annexe] (
    [article]       VARCHAR (10)   NOT NULL,
    [libelle]       NVARCHAR (300) NOT NULL,
    [source_valeur] VARCHAR (14)   NOT NULL,
    [cellules]      INT            NULL,
    [note]          NVARCHAR (600) NULL,
    [ordre]         INT            NOT NULL,
    [modifie_par]   NVARCHAR (400) NULL,
    [modifie_le]    DATETIME2 (3)  NULL,
    [indicatif]     INT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [pk_ref_tableau_annexe] PRIMARY KEY CLUSTERED ([article] ASC),
    CONSTRAINT [ck_tableau_source] CHECK ([source_valeur]='MIXTE' OR [source_valeur]='CALCUL' OR [source_valeur]='SAISIE'),
    CONSTRAINT [uq_ref_tableau_annexe_ordre] UNIQUE NONCLUSTERED ([ordre] ASC)
);


GO

CREATE   TRIGGER dbo.[tr_ref_tableau_annexe_garde]
ON dbo.[ref_tableau_annexe]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_tableau_annexe',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_tableau_annexe_horodatage]
ON dbo.[ref_tableau_annexe]
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
    FROM dbo.[ref_tableau_annexe] t
    JOIN inserted i ON t.[article] = i.[article];
END;

GO

