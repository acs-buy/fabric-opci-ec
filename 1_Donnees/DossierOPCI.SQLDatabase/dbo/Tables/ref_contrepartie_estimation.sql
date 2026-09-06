CREATE TABLE [dbo].[ref_contrepartie_estimation] (
    [compte_estimation]   VARCHAR (20)   NOT NULL,
    [compte_contrepartie] VARCHAR (20)   NOT NULL,
    [motif]               NVARCHAR (300) NOT NULL,
    [article]             VARCHAR (40)   NOT NULL,
    [modifie_par]         NVARCHAR (400) NULL,
    [modifie_le]          DATETIME2 (3)  NULL,
    [reference_id]        INT            NULL,
    CONSTRAINT [pk_ref_contrepartie_estimation] PRIMARY KEY CLUSTERED ([compte_estimation] ASC),
    CONSTRAINT [fk_contrepartie_reference] FOREIGN KEY ([reference_id]) REFERENCES [dbo].[ref_reference] ([id]),
    CONSTRAINT [fk_rce_contrepartie] FOREIGN KEY ([compte_contrepartie]) REFERENCES [dbo].[ref_compte] ([compte]),
    CONSTRAINT [fk_rce_estimation] FOREIGN KEY ([compte_estimation]) REFERENCES [dbo].[ref_compte] ([compte])
);


GO

CREATE   TRIGGER dbo.[tr_ref_contrepartie_estimation_garde]
ON dbo.[ref_contrepartie_estimation]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_contrepartie_estimation',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_contrepartie_estimation_horodatage]
ON dbo.[ref_contrepartie_estimation]
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
    FROM dbo.[ref_contrepartie_estimation] t
    JOIN inserted i ON t.[compte_estimation] = i.[compte_estimation];
END;

GO

