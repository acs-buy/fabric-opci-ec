CREATE TABLE [dbo].[ref_reference] (
    [id]              INT            IDENTITY (1, 1) NOT NULL,
    [norme]           VARCHAR (14)   NOT NULL,
    [reference]       VARCHAR (20)   NOT NULL,
    [genre]           VARCHAR (10)   NOT NULL,
    [intitule]        NVARCHAR (300) NOT NULL,
    [citation]        NVARCHAR (MAX) NULL,
    [lu_sur_piece]    INT            DEFAULT ((0)) NOT NULL,
    [page_piece]      INT            NULL,
    [piece_reference] NVARCHAR (400) NULL,
    [lu_le]           DATE           NULL,
    [modifie_par]     NVARCHAR (400) NULL,
    [modifie_le]      DATETIME2 (3)  NULL,
    [abroge_le]       DATE           NULL,
    [abroge_par]      NVARCHAR (400) NULL,
    CONSTRAINT [pk_ref_reference] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_reference_abrogee] CHECK ([abroge_le] IS NULL OR [abroge_par] IS NOT NULL),
    CONSTRAINT [ck_reference_bit] CHECK ([lu_sur_piece]=(1) OR [lu_sur_piece]=(0)),
    CONSTRAINT [ck_reference_genre] CHECK ([genre]='TITRE' OR [genre]='ANNEXE' OR [genre]='PARAGRAPHE' OR [genre]='ARTICLE'),
    CONSTRAINT [ck_reference_lue] CHECK ([lu_sur_piece]=(0) OR [lu_le] IS NOT NULL AND ([page_piece] IS NOT NULL OR [piece_reference] IS NOT NULL)),
    CONSTRAINT [fk_reference_norme] FOREIGN KEY ([norme]) REFERENCES [dbo].[ref_norme] ([code]),
    CONSTRAINT [uq_ref_reference] UNIQUE NONCLUSTERED ([norme] ASC, [reference] ASC)
);


GO

CREATE NONCLUSTERED INDEX [ix_ref_reference_norme]
    ON [dbo].[ref_reference]([norme] ASC, [reference] ASC);


GO

CREATE   TRIGGER dbo.[tr_ref_reference_garde]
ON dbo.[ref_reference]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_reference',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_reference_horodatage]
ON dbo.[ref_reference]
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
    FROM dbo.[ref_reference] t
    JOIN inserted i ON t.[id] = i.[id];
END;

GO

