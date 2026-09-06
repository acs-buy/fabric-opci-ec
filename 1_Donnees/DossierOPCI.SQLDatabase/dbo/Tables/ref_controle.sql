CREATE TABLE [dbo].[ref_controle] (
    [vue]                VARCHAR (120)   NOT NULL,
    [code]               VARCHAR (10)    NULL,
    [libelle]            NVARCHAR (300)  NOT NULL,
    [genre]              VARCHAR (20)    NOT NULL,
    [condition_anomalie] NVARCHAR (400)  NULL,
    [fondement]          NVARCHAR (1000) NULL,
    [ordre]              INT             NOT NULL,
    [modifie_par]        NVARCHAR (400)  NULL,
    [modifie_le]         DATETIME2 (3)   NULL,
    CONSTRAINT [pk_ref_controle] PRIMARY KEY CLUSTERED ([vue] ASC),
    CONSTRAINT [ck_controle_condition] CHECK ([genre]='RAPPROCHEMENT' AND [condition_anomalie] IS NOT NULL OR [genre]<>'RAPPROCHEMENT' AND [condition_anomalie] IS NULL),
    CONSTRAINT [ck_controle_genre] CHECK ([genre]='MESURE' OR [genre]='RAPPROCHEMENT' OR [genre]='ZERO_ATTENDU')
);


GO

CREATE   TRIGGER dbo.[tr_ref_controle_garde]
ON dbo.[ref_controle]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_controle',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_controle_horodatage]
ON dbo.[ref_controle]
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
    FROM dbo.[ref_controle] t
    JOIN inserted i ON t.[vue] = i.[vue];
END;

GO

