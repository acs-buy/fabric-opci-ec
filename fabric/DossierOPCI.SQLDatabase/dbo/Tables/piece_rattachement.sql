CREATE TABLE [dbo].[piece_rattachement] (
    [id]                INT            IDENTITY (1, 1) NOT NULL,
    [piece_id]          INT            NOT NULL,
    [entite]            VARCHAR (20)   NULL,
    [code_actif]        VARCHAR (20)   NULL,
    [question_id]       INT            NULL,
    [arrete]            VARCHAR (20)   NULL,
    [rattache_par]      NVARCHAR (200) NOT NULL,
    [rattache_le]       DATETIME2 (7)  DEFAULT (sysutcdatetime()) NOT NULL,
    [piece_attendue_id] INT            NULL,
    [entite_couverte]   VARCHAR (20)   NULL,
    [arrete_couvert]    VARCHAR (20)   NULL,
    CONSTRAINT [pk_piece_rattachement] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_pr_au_moins_une_cible] CHECK ([entite] IS NOT NULL OR [code_actif] IS NOT NULL OR [question_id] IS NOT NULL),
    CONSTRAINT [fk_pr_actif] FOREIGN KEY ([code_actif]) REFERENCES [dbo].[actif] ([code]),
    CONSTRAINT [fk_pr_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_pr_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_pr_entite_couverte] FOREIGN KEY ([entite_couverte]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_pr_piece] FOREIGN KEY ([piece_id]) REFERENCES [dbo].[piece] ([id]),
    CONSTRAINT [fk_pr_piece_attendue] FOREIGN KEY ([piece_attendue_id]) REFERENCES [dbo].[ref_piece_attendue] ([id]),
    CONSTRAINT [fk_pr_question] FOREIGN KEY ([question_id]) REFERENCES [dbo].[ref_question] ([id])
);


GO

CREATE NONCLUSTERED INDEX [ix_pr_actif]
    ON [dbo].[piece_rattachement]([code_actif] ASC);


GO

CREATE NONCLUSTERED INDEX [ix_pr_piece]
    ON [dbo].[piece_rattachement]([piece_id] ASC);


GO

CREATE UNIQUE NONCLUSTERED INDEX [uq_piece_rattachement]
    ON [dbo].[piece_rattachement]([piece_id] ASC, [piece_attendue_id] ASC, [entite_couverte] ASC, [arrete_couvert] ASC) WHERE ([piece_attendue_id] IS NOT NULL);


GO


-- --- 5 : le verrou K6, le rattachement au premier arrete -----------
-- Une piece de periodicite PERMANENT se rattache au PREMIER arrete de
-- l'entite. La rattacher a un arrete ulterieur ferait croire que la
-- lettre de mission a ete signee en cours de dossier, et la vue des
-- documents attendus ne la compterait pas au premier arrete, ou elle est
-- exigee.
CREATE   TRIGGER dbo.tr_rattachement_permanent_premier_arrete
ON dbo.piece_rattachement
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN dbo.ref_piece_attendue a ON a.id = i.piece_attendue_id
        WHERE a.periodicite = 'PERMANENT'
          AND i.arrete_couvert IS NOT NULL
          AND i.entite_couverte IS NOT NULL
          AND EXISTS (
              SELECT 1 FROM dbo.ref_arrete r
              WHERE r.entite = i.entite_couverte AND r.arrete = i.arrete_couvert
                AND r.date_arrete > (SELECT MIN(r2.date_arrete)
                                     FROM dbo.ref_arrete r2
                                     WHERE r2.entite = i.entite_couverte
                                       AND r2.porte_balance = 1))
    )
        THROW 50067, 'Rattachement refuse : cette piece est de periodicite PERMANENT et se rattache au PREMIER arrete de l''entite, non a un arrete ulterieur. La rattacher plus tard ferait croire qu''elle a ete obtenue en cours de dossier, et la vue des documents attendus ne la compterait pas la ou elle est exigee.', 1;
END

GO

