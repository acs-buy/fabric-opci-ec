CREATE TABLE [dbo].[ref_livrable] (
    [code]        VARCHAR (20)   NOT NULL,
    [libelle]     NVARCHAR (200) NOT NULL,
    [nature]      VARCHAR (20)   NOT NULL,
    [applicable]  VARCHAR (20)   NOT NULL,
    [article]     NVARCHAR (200) NULL,
    [ordre]       INT            NOT NULL,
    [modifie_par] NVARCHAR (400) NULL,
    [modifie_le]  DATETIME2 (3)  NULL,
    CONSTRAINT [pk_ref_livrable] PRIMARY KEY CLUSTERED ([code] ASC),
    CONSTRAINT [ck_livrable_applicable] CHECK ([applicable]='LES_DEUX' OR [applicable]='ARRETE_CLOTURE' OR [applicable]='ARRETE_VL'),
    CONSTRAINT [uq_ref_livrable_ordre] UNIQUE NONCLUSTERED ([ordre] ASC)
);


GO

CREATE   TRIGGER dbo.[tr_ref_livrable_garde]
ON dbo.[ref_livrable]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_livrable',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_livrable_horodatage]
ON dbo.[ref_livrable]
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
    FROM dbo.[ref_livrable] t
    JOIN inserted i ON t.[code] = i.[code];
END;

GO

