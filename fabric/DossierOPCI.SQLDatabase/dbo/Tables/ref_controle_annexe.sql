CREATE TABLE [dbo].[ref_controle_annexe] (
    [controle] VARCHAR (24)   NOT NULL,
    [article]  VARCHAR (40)   NOT NULL,
    [libelle]  NVARCHAR (400) NOT NULL,
    [obstacle] BIT            NOT NULL,
    CONSTRAINT [pk_ref_controle_annexe] PRIMARY KEY CLUSTERED ([controle] ASC)
);


GO

