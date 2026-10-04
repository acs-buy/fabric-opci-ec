CREATE TABLE [dbo].[od_reimport] (
    [id]      INT IDENTITY (1, 1) NOT NULL,
    [entite]  VARCHAR (20) NOT NULL,
    [arrete]  VARCHAR (20) NOT NULL,
    [fichier] NVARCHAR (400) NOT NULL,
    [lignes]  INT NOT NULL,
    [par]     NVARCHAR (400) NOT NULL,
    [le]      DATETIME2 (3) NOT NULL,
    CONSTRAINT [pk_od_reimport] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_od_reimport_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete])
);


GO

