CREATE TABLE [dbo].[ref_question_article] (
    [question_id] INT            NOT NULL,
    [article]     VARCHAR (10)   NOT NULL,
    [nature]      VARCHAR (30)   NOT NULL,
    [modifie_par] NVARCHAR (400) NULL,
    [modifie_le]  DATETIME2 (3)  NULL,
    CONSTRAINT [pk_ref_question_article] PRIMARY KEY CLUSTERED ([question_id] ASC, [article] ASC),
    CONSTRAINT [ck_rqa_nature] CHECK ([nature]='INFORMATION_ANNEXE' OR [nature]='PRODUCTION_ETAT' OR [nature]='DILIGENCE'),
    CONSTRAINT [fk_rqa_article] FOREIGN KEY ([article]) REFERENCES [dbo].[ref_article] ([article]),
    CONSTRAINT [fk_rqa_question] FOREIGN KEY ([question_id]) REFERENCES [dbo].[ref_question] ([id])
);


GO

CREATE NONCLUSTERED INDEX [ix_rqa_article]
    ON [dbo].[ref_question_article]([article] ASC);


GO

CREATE   TRIGGER dbo.[tr_ref_question_article_garde]
ON dbo.[ref_question_article]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_question_article',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_question_article_horodatage]
ON dbo.[ref_question_article]
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
    FROM dbo.[ref_question_article] t
    JOIN inserted i ON t.[question_id] = i.[question_id] AND t.[article] = i.[article];
END;

GO

