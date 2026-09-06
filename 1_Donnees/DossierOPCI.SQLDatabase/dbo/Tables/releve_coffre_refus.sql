CREATE TABLE [dbo].[releve_coffre_refus] (
    [id]            INT            IDENTITY (1, 1) NOT NULL,
    [releve_id]     INT            NOT NULL,
    [chemin]        NVARCHAR (800) NOT NULL,
    [empreinte]     CHAR (64)      NULL,
    [motif]         NVARCHAR (600) NOT NULL,
    [piece_en_face] INT            NULL,
    CONSTRAINT [pk_releve_coffre_refus] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_rcr_empreinte] CHECK ([empreinte] IS NULL OR len([empreinte])=(64)),
    CONSTRAINT [fk_rcr_piece] FOREIGN KEY ([piece_en_face]) REFERENCES [dbo].[piece] ([id]),
    CONSTRAINT [fk_rcr_releve] FOREIGN KEY ([releve_id]) REFERENCES [dbo].[releve_coffre] ([id])
);


GO

CREATE NONCLUSTERED INDEX [ix_rcr_releve]
    ON [dbo].[releve_coffre_refus]([releve_id] ASC);


GO

