CREATE TABLE [dbo].[ref_question_modele] (
    [question_id] INT            NOT NULL,
    [modele_code] VARCHAR (20)   NOT NULL,
    [modifie_par] NVARCHAR (400) NULL,
    [modifie_le]  DATETIME2 (3)  NULL,
    CONSTRAINT [pk_ref_question_modele] PRIMARY KEY CLUSTERED ([question_id] ASC, [modele_code] ASC),
    CONSTRAINT [fk_rqm_modele] FOREIGN KEY ([modele_code]) REFERENCES [dbo].[modele_feuille] ([code]),
    CONSTRAINT [fk_rqm_question] FOREIGN KEY ([question_id]) REFERENCES [dbo].[ref_question] ([id])
);


GO

CREATE   TRIGGER dbo.[tr_ref_question_modele_garde]
ON dbo.[ref_question_modele]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_question_modele',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_question_modele_horodatage]
ON dbo.[ref_question_modele]
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
    FROM dbo.[ref_question_modele] t
    JOIN inserted i ON t.[question_id] = i.[question_id] AND t.[modele_code] = i.[modele_code];
END;

GO

