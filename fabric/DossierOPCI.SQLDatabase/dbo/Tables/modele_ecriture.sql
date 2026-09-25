CREATE TABLE [dbo].[modele_ecriture] (
    [id]          INT            IDENTITY (1, 1) NOT NULL,
    [question_id] INT            NOT NULL,
    [ordre]       INT            NOT NULL,
    [compte_num]  VARCHAR (20)   NOT NULL,
    [sens]        VARCHAR (6)    NOT NULL,
    [libelle]     NVARCHAR (200) NOT NULL,
    [source]      NVARCHAR (400) NOT NULL,
    [modifie_par] NVARCHAR (400) NULL,
    [modifie_le]  DATETIME2 (3)  NULL,
    CONSTRAINT [pk_modele_ecriture] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_me_sens] CHECK ([sens]='CREDIT' OR [sens]='DEBIT'),
    CONSTRAINT [fk_me_compte] FOREIGN KEY ([compte_num]) REFERENCES [dbo].[ref_compte] ([compte]),
    CONSTRAINT [fk_me_question] FOREIGN KEY ([question_id]) REFERENCES [dbo].[ref_question] ([id]),
    CONSTRAINT [uq_modele_ecriture] UNIQUE NONCLUSTERED ([question_id] ASC, [ordre] ASC)
);


GO

CREATE   TRIGGER dbo.[tr_modele_ecriture_garde]
ON dbo.[modele_ecriture]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('modele_ecriture',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_modele_ecriture_horodatage]
ON dbo.[modele_ecriture]
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
    FROM dbo.[modele_ecriture] t
    JOIN inserted i ON t.[id] = i.[id];
END;

GO

