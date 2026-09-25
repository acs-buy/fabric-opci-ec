CREATE TABLE [dbo].[conclusion_cycle] (
    [id]                INT             IDENTITY (1, 1) NOT NULL,
    [entite]            VARCHAR (20)    NOT NULL,
    [arrete]            VARCHAR (20)    NOT NULL,
    [cycle]             VARCHAR (10)    NOT NULL,
    [synthese_feuilles] NVARCHAR (MAX)  NULL,
    [conclusion]        NVARCHAR (2000) NOT NULL,
    [forme]             VARCHAR (20)    NULL,
    [conclu_par]        NVARCHAR (400)  NOT NULL,
    [conclu_le]         DATETIME2 (3)   DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [pk_conclusion_cycle] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_cc_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_cc_cycle] FOREIGN KEY ([cycle]) REFERENCES [dbo].[ref_cycle] ([code]),
    CONSTRAINT [fk_cc_forme] FOREIGN KEY ([forme]) REFERENCES [dbo].[ref_forme_conclusion] ([code]),
    CONSTRAINT [uq_conclusion_cycle] UNIQUE NONCLUSTERED ([entite] ASC, [arrete] ASC, [cycle] ASC)
);


GO

