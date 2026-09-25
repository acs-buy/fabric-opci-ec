CREATE TABLE [dbo].[dossier_verrou] (
    [entite]           VARCHAR (20)   NOT NULL,
    [arrete]           VARCHAR (20)   NOT NULL,
    [verrouille]       BIT            DEFAULT ((1)) NOT NULL,
    [verrouille_par]   NVARCHAR (400) NOT NULL,
    [verrouille_le]    DATETIME2 (3)  DEFAULT (sysutcdatetime()) NOT NULL,
    [deverrouille_par] NVARCHAR (400) NULL,
    [deverrouille_le]  DATETIME2 (3)  NULL,
    CONSTRAINT [pk_dossier_verrou] PRIMARY KEY CLUSTERED ([entite] ASC, [arrete] ASC),
    CONSTRAINT [fk_dv_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete])
);


GO

