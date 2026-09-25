CREATE TABLE [dbo].[parts_en_circulation] (
    [entite]       VARCHAR (20)    NOT NULL,
    [arrete]       VARCHAR (20)    NOT NULL,
    [nombre_parts] DECIMAL (19, 4) NOT NULL,
    [source]       NVARCHAR (200)  NOT NULL,
    [saisi_par]    NVARCHAR (400)  NULL,
    [saisi_le]     DATETIME2 (3)   NULL,
    CONSTRAINT [pk_parts_en_circulation] PRIMARY KEY CLUSTERED ([entite] ASC, [arrete] ASC),
    CONSTRAINT [ck_parts_positives] CHECK ([nombre_parts]>(0)),
    CONSTRAINT [fk_parts_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_parts_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code])
);


GO

