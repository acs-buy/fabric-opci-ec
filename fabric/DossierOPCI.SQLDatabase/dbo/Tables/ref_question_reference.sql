CREATE TABLE [dbo].[ref_question_reference] (
    [question_reference] VARCHAR (20)   NOT NULL,
    [reference_id]       INT            NOT NULL,
    [modifie_par]        NVARCHAR (400) NULL,
    [modifie_le]         DATETIME2 (3)  NULL,
    CONSTRAINT [pk_ref_question_reference] PRIMARY KEY CLUSTERED ([question_reference] ASC, [reference_id] ASC),
    CONSTRAINT [fk_rqr_question] FOREIGN KEY ([question_reference]) REFERENCES [dbo].[ref_question] ([reference]),
    CONSTRAINT [fk_rqr_reference] FOREIGN KEY ([reference_id]) REFERENCES [dbo].[ref_reference] ([id])
);


GO

CREATE   TRIGGER dbo.[tr_ref_question_reference_garde]
ON dbo.[ref_question_reference]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_question_reference',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_question_reference_horodatage]
ON dbo.[ref_question_reference]
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
    FROM dbo.[ref_question_reference] t
    JOIN inserted i ON t.[question_reference] = i.[question_reference] AND t.[reference_id] = i.[reference_id];
END;

GO

