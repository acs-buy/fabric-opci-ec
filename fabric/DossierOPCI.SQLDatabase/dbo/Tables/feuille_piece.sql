CREATE TABLE [dbo].[feuille_piece] (
    [cote]     VARCHAR (30) NOT NULL,
    [piece_id] INT          NOT NULL,
    CONSTRAINT [pk_feuille_piece] PRIMARY KEY CLUSTERED ([cote] ASC, [piece_id] ASC),
    CONSTRAINT [fk_fp_feuille] FOREIGN KEY ([cote]) REFERENCES [dbo].[feuille_travail] ([cote]),
    CONSTRAINT [fk_fp_piece] FOREIGN KEY ([piece_id]) REFERENCES [dbo].[piece] ([id])
);


GO

