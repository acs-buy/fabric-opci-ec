CREATE TABLE [dbo].[controle_annexe] (
    [entite]    VARCHAR (20)    NOT NULL,
    [arrete]    VARCHAR (20)    NOT NULL,
    [controle]  VARCHAR (24)    NOT NULL,
    [cle]       NVARCHAR (120)  NOT NULL,
    [article]   VARCHAR (40)    NOT NULL,
    [ecart]     DECIMAL (19, 2) NOT NULL,
    [effet]     VARCHAR (8)     NOT NULL,
    [version]   INT             NOT NULL,
    [calcul_id] INT             NOT NULL,
    CONSTRAINT [pk_controle_annexe] PRIMARY KEY CLUSTERED ([entite] ASC, [arrete] ASC, [controle] ASC, [cle] ASC),
    CONSTRAINT [ck_controle_annexe_effet] CHECK ([effet]='signal' OR [effet]='obstacle'),
    CONSTRAINT [fk_controle_annexe_ref] FOREIGN KEY ([controle]) REFERENCES [dbo].[ref_controle_annexe] ([controle])
);


GO

