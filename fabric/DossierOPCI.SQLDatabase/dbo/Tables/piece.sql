CREATE TABLE [dbo].[piece] (
    [id]               INT            IDENTITY (1, 1) NOT NULL,
    [nom_fichier]      NVARCHAR (400) NOT NULL,
    [chemin_coffre]    NVARCHAR (400) NOT NULL,
    [empreinte_sha256] CHAR (64)      NOT NULL,
    [nature]           VARCHAR (40)   NOT NULL,
    [periode_debut]    DATE           NULL,
    [periode_fin]      DATE           NULL,
    [depose_par]       NVARCHAR (200) NOT NULL,
    [depose_le]        DATETIME2 (7)  DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [pk_piece] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_piece_empreinte_longueur] CHECK (len([empreinte_sha256])=(64)),
    CONSTRAINT [ck_piece_periode] CHECK ([periode_debut] IS NULL OR [periode_fin] IS NULL OR [periode_debut]<=[periode_fin]),
    CONSTRAINT [fk_piece_nature] FOREIGN KEY ([nature]) REFERENCES [dbo].[ref_nature_piece] ([code]),
    CONSTRAINT [uq_piece_empreinte] UNIQUE NONCLUSTERED ([empreinte_sha256] ASC)
);


GO

