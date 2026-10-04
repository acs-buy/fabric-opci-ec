CREATE TABLE [dbo].[ref_forme_rapport] (
    [code]        VARCHAR (20)   NOT NULL,
    [exemple]     VARCHAR (4)    NOT NULL,
    [page_np]     INT            NOT NULL,
    [libelle]     NVARCHAR (300) NOT NULL,
    [intitule]    NVARCHAR (100) NOT NULL,
    [attestation] BIT            NOT NULL,
    [fondement]   NVARCHAR (100) NOT NULL,
    [texte]       NVARCHAR (MAX) NOT NULL,
    [ordre]       INT            NOT NULL,
    [modifie_par] NVARCHAR (400) NULL,
    [modifie_le]  DATETIME2 (3)  NULL,
    CONSTRAINT [pk_ref_forme_rapport] PRIMARY KEY CLUSTERED ([code] ASC),
    CONSTRAINT [ck_ref_forme_rapport_code] CHECK ([code]='IMPOSSIBILITE' OR [code]='AVEC_OBSERVATION' OR [code]='SANS_OBSERVATION' OR [code]='COMPTE_RENDU_TRAVAUX')
);


GO

CREATE   TRIGGER dbo.[tr_ref_forme_rapport_horodatage]
ON dbo.[ref_forme_rapport]
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
    FROM dbo.[ref_forme_rapport] t
    JOIN inserted i ON t.[code] = i.[code];
END;

GO

CREATE   TRIGGER dbo.[tr_ref_forme_rapport_garde]
ON dbo.[ref_forme_rapport]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_forme_rapport',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Cette table porte des valeurs livrées avec la base, recopiées depuis un texte : les modifier les fait diverger de leur source. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO
