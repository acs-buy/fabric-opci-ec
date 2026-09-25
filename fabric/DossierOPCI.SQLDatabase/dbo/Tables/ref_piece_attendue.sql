CREATE TABLE [dbo].[ref_piece_attendue] (
    [id]                  INT            IDENTITY (1, 1) NOT NULL,
    [cycle]               VARCHAR (10)   NULL,
    [phase]               VARCHAR (10)   NULL,
    [libelle]             NVARCHAR (200) NOT NULL,
    [obligatoire]         INT            DEFAULT ((1)) NOT NULL,
    [periodicite]         VARCHAR (20)   NOT NULL,
    [racine_declenchante] VARCHAR (10)   NULL,
    [ordre]               INT            NOT NULL,
    [modifie_par]         NVARCHAR (400) NULL,
    [modifie_le]          DATETIME2 (3)  NULL,
    [en_vigueur_depuis]   DATE           NULL,
    CONSTRAINT [pk_ref_piece_attendue] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_rpa_obligatoire] CHECK ([obligatoire]=(1) OR [obligatoire]=(0)),
    CONSTRAINT [ck_rpa_periodicite] CHECK ([periodicite]='EVENEMENT' OR [periodicite]='ARRETE' OR [periodicite]='PERMANENT'),
    CONSTRAINT [ck_rpa_racine_si_evenement] CHECK ([periodicite]='EVENEMENT' AND [racine_declenchante] IS NOT NULL OR [periodicite]<>'EVENEMENT' AND [racine_declenchante] IS NULL),
    CONSTRAINT [ck_rpa_un_seul_proprietaire] CHECK ([cycle] IS NOT NULL AND [phase] IS NULL OR [cycle] IS NULL AND [phase] IS NOT NULL),
    CONSTRAINT [fk_rpa_cycle] FOREIGN KEY ([cycle]) REFERENCES [dbo].[ref_cycle] ([code]),
    CONSTRAINT [fk_rpa_phase] FOREIGN KEY ([phase]) REFERENCES [dbo].[ref_phase] ([code]),
    CONSTRAINT [uq_rpa_proprietaire_libelle] UNIQUE NONCLUSTERED ([cycle] ASC, [phase] ASC, [libelle] ASC)
);


GO

CREATE NONCLUSTERED INDEX [ix_rpa_cycle]
    ON [dbo].[ref_piece_attendue]([cycle] ASC);


GO

CREATE NONCLUSTERED INDEX [ix_rpa_phase]
    ON [dbo].[ref_piece_attendue]([phase] ASC);


GO

CREATE   TRIGGER dbo.[tr_ref_piece_attendue_garde]
ON dbo.[ref_piece_attendue]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_piece_attendue',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_piece_attendue_horodatage]
ON dbo.[ref_piece_attendue]
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
    FROM dbo.[ref_piece_attendue] t
    JOIN inserted i ON t.[id] = i.[id];
END;

GO

