CREATE TABLE [dbo].[ref_categorie_actif_cmf] (
    [rang]        INT            NOT NULL,
    [libelle]     NVARCHAR (300) NOT NULL,
    [racines]     VARCHAR (200)  NULL,
    [note]        NVARCHAR (400) NULL,
    [modifie_par] NVARCHAR (400) NULL,
    [modifie_le]  DATETIME2 (3)  NULL,
    CONSTRAINT [pk_ref_categorie_actif_cmf] PRIMARY KEY CLUSTERED ([rang] ASC)
);


GO

CREATE   TRIGGER dbo.[tr_ref_categorie_actif_cmf_garde]
ON dbo.[ref_categorie_actif_cmf]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_categorie_actif_cmf',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_categorie_actif_cmf_horodatage]
ON dbo.[ref_categorie_actif_cmf]
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
    FROM dbo.[ref_categorie_actif_cmf] t
    JOIN inserted i ON t.[rang] = i.[rang];
END;

GO

