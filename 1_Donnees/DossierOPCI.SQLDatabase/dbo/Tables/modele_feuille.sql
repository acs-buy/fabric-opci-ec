CREATE TABLE [dbo].[modele_feuille] (
    [code]              VARCHAR (20)   NOT NULL,
    [libelle]           NVARCHAR (200) NOT NULL,
    [standard]          INT            DEFAULT ((0)) NOT NULL,
    [nom_fichier]       NVARCHAR (400) NULL,
    [chemin_coffre]     NVARCHAR (400) NULL,
    [empreinte_sha256]  CHAR (64)      NULL,
    [version]           VARCHAR (20)   NOT NULL,
    [en_vigueur_depuis] DATE           NOT NULL,
    [modifie_par]       NVARCHAR (400) NULL,
    [modifie_le]        DATETIME2 (3)  NULL,
    CONSTRAINT [pk_modele_feuille] PRIMARY KEY CLUSTERED ([code] ASC),
    CONSTRAINT [ck_mf_standard] CHECK ([standard]=(1) OR [standard]=(0))
);


GO

CREATE   TRIGGER dbo.[tr_modele_feuille_garde]
ON dbo.[modele_feuille]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('modele_feuille',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_modele_feuille_horodatage]
ON dbo.[modele_feuille]
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
    FROM dbo.[modele_feuille] t
    JOIN inserted i ON t.[code] = i.[code];
END;

GO

