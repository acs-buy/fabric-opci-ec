CREATE TABLE [dbo].[conclusion_ratio] (
    [id]         INT            IDENTITY (1, 1) NOT NULL,
    [entite]     VARCHAR (20)   NOT NULL,
    [arrete]     VARCHAR (20)   NOT NULL,
    [code]       VARCHAR (30)   NOT NULL,
    [conclusion] NVARCHAR (600) NOT NULL,
    [conclu_par] NVARCHAR (400) NOT NULL,
    [conclu_le]  DATETIME2 (0)  CONSTRAINT [df_crat_conclu_le] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [pk_conclusion_ratio] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_crat_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_crat_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_crat_ratio_memoire] FOREIGN KEY ([code]) REFERENCES [dbo].[ref_ratio_memoire] ([code]),
    CONSTRAINT [uq_conclusion_ratio] UNIQUE NONCLUSTERED ([entite] ASC, [arrete] ASC, [code] ASC)
);


GO

