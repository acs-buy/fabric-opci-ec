CREATE TABLE [dbo].[ecriture_axe] (
    [ecriture_id] INT          NOT NULL,
    [entite]      VARCHAR (20) NULL,
    [code_actif]  VARCHAR (20) NULL,
    [code_projet] VARCHAR (20) NULL,
    [code_lot]    VARCHAR (20) NULL,
    PRIMARY KEY CLUSTERED ([ecriture_id] ASC),
    FOREIGN KEY ([code_actif]) REFERENCES [dbo].[actif] ([code]),
    FOREIGN KEY ([ecriture_id]) REFERENCES [dbo].[ecriture] ([id]),
    CONSTRAINT [fk_ecriture_axe_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code])
);


GO

CREATE NONCLUSTERED INDEX [ix_ecriture_axe_actif]
    ON [dbo].[ecriture_axe]([code_actif] ASC);


GO

