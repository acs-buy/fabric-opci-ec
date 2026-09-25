CREATE TABLE [dbo].[ref_rubrique_resultat] (
    [code]        VARCHAR (14)   NOT NULL,
    [romain]      VARCHAR (6)    NULL,
    [libelle]     NVARCHAR (200) NOT NULL,
    [famille]     VARCHAR (14)   NOT NULL,
    [source]      NVARCHAR (300) NOT NULL,
    [ordre]       INT            NOT NULL,
    [modifie_par] NVARCHAR (400) NULL,
    [modifie_le]  DATETIME2 (3)  NULL,
    CONSTRAINT [pk_ref_rubrique_resultat] PRIMARY KEY CLUSTERED ([code] ASC),
    CONSTRAINT [ck_rubrique_famille] CHECK ([famille]='REGULARISATION' OR [famille]='PMV' OR [famille]='AUTRE' OR [famille]='CORPORATE' OR [famille]='FINANCIER' OR [famille]='IMMOBILIER'),
    CONSTRAINT [uq_ref_rubrique_resultat_ordre] UNIQUE NONCLUSTERED ([ordre] ASC)
);


GO

CREATE   TRIGGER dbo.[tr_ref_rubrique_resultat_garde]
ON dbo.[ref_rubrique_resultat]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_rubrique_resultat',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_rubrique_resultat_horodatage]
ON dbo.[ref_rubrique_resultat]
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
    FROM dbo.[ref_rubrique_resultat] t
    JOIN inserted i ON t.[code] = i.[code];
END;

GO

