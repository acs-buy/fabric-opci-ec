CREATE TABLE [dbo].[ref_compte] (
    [compte]            VARCHAR (20)   NOT NULL,
    [libelle]           NVARCHAR (200) NOT NULL,
    [libelle_complet]   NVARCHAR (300) NULL,
    [classe]            CHAR (1)       NOT NULL,
    [niveau]            TINYINT        NOT NULL,
    [compte_parent]     VARCHAR (20)   NULL,
    [porte_actif]       INT            CONSTRAINT [df_ref_compte_porte_actif] DEFAULT ((0)) NOT NULL,
    [modifie_par]       NVARCHAR (400) NULL,
    [modifie_le]        DATETIME2 (3)  NULL,
    [source_article]    VARCHAR (60)   NULL,
    [reference_id]      INT            NULL,
    [rubrique_resultat] VARCHAR (14)   NULL,
    PRIMARY KEY CLUSTERED ([compte] ASC),
    CONSTRAINT [ck_ref_compte_porte_actif] CHECK ([porte_actif]=(1) OR [porte_actif]=(0)),
    FOREIGN KEY ([compte_parent]) REFERENCES [dbo].[ref_compte] ([compte]),
    CONSTRAINT [fk_compte_reference] FOREIGN KEY ([reference_id]) REFERENCES [dbo].[ref_reference] ([id]),
    CONSTRAINT [fk_compte_rubrique] FOREIGN KEY ([rubrique_resultat]) REFERENCES [dbo].[ref_rubrique_resultat] ([code])
);


GO

CREATE   TRIGGER dbo.[tr_ref_compte_horodatage]
ON dbo.[ref_compte]
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
    FROM dbo.[ref_compte] t
    JOIN inserted i ON t.[compte] = i.[compte];
END;

GO

CREATE   TRIGGER dbo.[tr_ref_compte_garde]
ON dbo.[ref_compte]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_compte',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO


CREATE   TRIGGER dbo.tr_ref_compte_annexe_retard ON dbo.ref_compte
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
    ;WITH ch AS (
        SELECT compte, libelle FROM inserted
        EXCEPT SELECT compte, libelle FROM deleted
        UNION ALL
        SELECT * FROM (SELECT compte, libelle FROM deleted EXCEPT SELECT compte, libelle FROM inserted) d
    )
    INSERT INTO dbo.annexe_retard (entite, ecrit_le, origine, lignes)
    SELECT e.code, SYSUTCDATETIME(), N'ref_compte', (SELECT COUNT(*) FROM ch)
    FROM dbo.ref_entite e WHERE e.forme_vehicule IS NOT NULL AND EXISTS (SELECT 1 FROM ch);
END;

GO

