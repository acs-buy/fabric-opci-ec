CREATE TABLE [dbo].[arrete_periodicite] (
    [entite]         VARCHAR (20)   NOT NULL,
    [arrete]         VARCHAR (20)   NOT NULL,
    [periodicite_vl] VARCHAR (13)   NOT NULL,
    [fixee_le]       DATETIME2 (3)  CONSTRAINT [df_arrete_periodicite_le] DEFAULT (sysutcdatetime()) NOT NULL,
    [fixee_par]      NVARCHAR (400) NOT NULL,
    CONSTRAINT [pk_arrete_periodicite] PRIMARY KEY CLUSTERED ([entite] ASC, [arrete] ASC),
    CONSTRAINT [ck_arrete_periodicite] CHECK ([periodicite_vl]='TRIMESTRIELLE' OR [periodicite_vl]='SEMESTRIELLE' OR [periodicite_vl]='ANNUELLE')
);


GO

