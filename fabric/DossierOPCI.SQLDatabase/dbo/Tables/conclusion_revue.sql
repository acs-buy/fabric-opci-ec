CREATE TABLE [dbo].[conclusion_revue] (
    [id]         INT             IDENTITY (1, 1) NOT NULL,
    [entite]     VARCHAR (20)    NOT NULL,
    [arrete]     VARCHAR (20)    NOT NULL,
    [conclusion] NVARCHAR (4000) NOT NULL,
    [conclu_par] NVARCHAR (400)  NOT NULL,
    [conclu_le]  DATETIME2 (3)   DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [pk_conclusion_revue] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_cr_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [uq_conclusion_revue] UNIQUE NONCLUSTERED ([entite] ASC, [arrete] ASC)
);


GO

