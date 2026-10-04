CREATE TABLE [dbo].[od_retrait] (
    [id]           INT IDENTITY (1, 1) NOT NULL,
    [entite]       VARCHAR (20) NOT NULL,
    [arrete]       VARCHAR (20) NOT NULL,
    [feuille_cote] VARCHAR (30) NOT NULL,
    [brouillon_id] INT NOT NULL,
    [compte_num]   VARCHAR (20) NOT NULL,
    [libelle]      NVARCHAR (200) NOT NULL,
    [debit]        DECIMAL (19, 2) NOT NULL,
    [credit]       DECIMAL (19, 2) NOT NULL,
    [piece_ref]    VARCHAR (50) NULL,
    [code_actif]   VARCHAR (20) NULL,
    [saisi_par]    NVARCHAR (200) NOT NULL,
    [saisi_le]     DATETIME2 (3) NOT NULL,
    [motif]        NVARCHAR (400) NULL,
    [retire_par]   NVARCHAR (400) NOT NULL,
    [retire_le]    DATETIME2 (3) CONSTRAINT [df_od_retrait_le] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [pk_od_retrait] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_od_retrait_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete])
);


GO

