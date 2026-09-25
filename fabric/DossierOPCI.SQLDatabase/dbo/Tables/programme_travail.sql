CREATE TABLE [dbo].[programme_travail] (
    [id]             INT            IDENTITY (1, 1) NOT NULL,
    [entite]         VARCHAR (20)   NOT NULL,
    [arrete]         VARCHAR (20)   NOT NULL,
    [type_programme] VARCHAR (10)   NOT NULL,
    [choisi_par]     NVARCHAR (400) NOT NULL,
    [choisi_le]      DATETIME2 (3)  DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [pk_programme_travail] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_programme_type] CHECK ([type_programme]='ETENDU' OR [type_programme]='CLASSIQUE' OR [type_programme]='ALLEGE'),
    CONSTRAINT [fk_programme_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [uq_programme_travail] UNIQUE NONCLUSTERED ([entite] ASC, [arrete] ASC)
);


GO

