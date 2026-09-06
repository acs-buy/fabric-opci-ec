CREATE TABLE [dbo].[ref_cas_eligibilite] (
    [cas]         CHAR (1)        NOT NULL,
    [libelle]     NVARCHAR (600)  NOT NULL,
    [citation]    NVARCHAR (1200) NOT NULL,
    [maitrise]    INT             NOT NULL,
    [note]        NVARCHAR (600)  NULL,
    [ordre]       INT             NOT NULL,
    [modifie_par] NVARCHAR (400)  NULL,
    [modifie_le]  DATETIME2 (3)   NULL,
    CONSTRAINT [pk_ref_cas_eligibilite] PRIMARY KEY CLUSTERED ([cas] ASC),
    CONSTRAINT [ck_cas_maitrise] CHECK ([maitrise]=(1) OR [maitrise]=(0)),
    CONSTRAINT [uq_ref_cas_eligibilite_ordre] UNIQUE NONCLUSTERED ([ordre] ASC)
);


GO

CREATE   TRIGGER dbo.[tr_ref_cas_eligibilite_garde]
ON dbo.[ref_cas_eligibilite]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_cas_eligibilite',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_cas_eligibilite_horodatage]
ON dbo.[ref_cas_eligibilite]
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
    FROM dbo.[ref_cas_eligibilite] t
    JOIN inserted i ON t.[cas] = i.[cas];
END;

GO

