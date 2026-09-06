CREATE TABLE [dbo].[ref_nature_piece] (
    [code]         VARCHAR (40)   NOT NULL,
    [libelle]      NVARCHAR (200) NOT NULL,
    [famille]      VARCHAR (20)   NOT NULL,
    [conservation] VARCHAR (20)   NOT NULL,
    [reference_id] INT            NULL,
    [ordre]        INT            NOT NULL,
    [source]       NVARCHAR (300) NOT NULL,
    [modifie_par]  NVARCHAR (400) NULL,
    [modifie_le]   DATETIME2 (3)  NULL,
    CONSTRAINT [pk_ref_nature_piece] PRIMARY KEY CLUSTERED ([code] ASC),
    CONSTRAINT [ck_rnp_conservation] CHECK ([conservation]='EXERCICE' OR [conservation]='DUREE_MISSION' OR [conservation]='PERMANENTE'),
    CONSTRAINT [ck_rnp_famille] CHECK ([famille]='FINANCIER' OR [famille]='JURIDIQUE' OR [famille]='IMMOBILIER' OR [famille]='COMPTABLE' OR [famille]='MISSION'),
    CONSTRAINT [fk_rnp_reference] FOREIGN KEY ([reference_id]) REFERENCES [dbo].[ref_reference] ([id])
);


GO

CREATE   TRIGGER dbo.[tr_ref_nature_piece_garde]
ON dbo.[ref_nature_piece]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_nature_piece',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_nature_piece_horodatage]
ON dbo.[ref_nature_piece]
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
    FROM dbo.[ref_nature_piece] t
    JOIN inserted i ON t.[code] = i.[code];
END;

GO

