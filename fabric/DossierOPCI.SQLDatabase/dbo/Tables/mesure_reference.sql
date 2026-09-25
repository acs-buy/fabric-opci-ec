CREATE TABLE [dbo].[mesure_reference] (
    [code]     VARCHAR (60)    NOT NULL,
    [libelle]  NVARCHAR (300)  NOT NULL,
    [cle]      NVARCHAR (120)  NOT NULL,
    [valeur]   DECIMAL (19, 2) NULL,
    [fige_le]  DATETIME2 (3)   DEFAULT (sysutcdatetime()) NOT NULL,
    [fige_par] NVARCHAR (400)  DEFAULT (suser_sname()) NOT NULL,
    [motif]    NVARCHAR (400)  NULL,
    CONSTRAINT [pk_mesure_reference] PRIMARY KEY CLUSTERED ([code] ASC, [cle] ASC)
);


GO

