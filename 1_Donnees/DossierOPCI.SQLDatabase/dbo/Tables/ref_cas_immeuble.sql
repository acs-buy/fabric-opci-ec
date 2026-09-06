CREATE TABLE [dbo].[ref_cas_immeuble] (
    [cas]         VARCHAR (10)    NOT NULL,
    [libelle]     NVARCHAR (600)  NOT NULL,
    [citation]    NVARCHAR (1200) NOT NULL,
    [note]        NVARCHAR (600)  NULL,
    [ordre]       INT             NOT NULL,
    [modifie_par] NVARCHAR (400)  NULL,
    [modifie_le]  DATETIME2 (3)   NULL,
    CONSTRAINT [pk_ref_cas_immeuble] PRIMARY KEY CLUSTERED ([cas] ASC),
    CONSTRAINT [uq_ref_cas_immeuble_ordre] UNIQUE NONCLUSTERED ([ordre] ASC)
);


GO

CREATE   TRIGGER dbo.[tr_ref_cas_immeuble_garde]
ON dbo.[ref_cas_immeuble]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_cas_immeuble',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Cette table porte des valeurs livrées avec la base, recopiées depuis un texte : les modifier les fait diverger de leur source. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_cas_immeuble_horodatage]
ON dbo.[ref_cas_immeuble]
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
    FROM dbo.[ref_cas_immeuble] t
    JOIN inserted i ON t.[cas] = i.[cas];
END;

GO

