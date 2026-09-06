CREATE TABLE [dbo].[ecriture_brouillon] (
    [id]                  INT             IDENTITY (1, 1) NOT NULL,
    [entite]              VARCHAR (20)    NOT NULL,
    [arrete]              VARCHAR (20)    NOT NULL,
    [feuille_cote]        VARCHAR (30)    NOT NULL,
    [journal_code]        VARCHAR (10)    DEFAULT ('ODR') NOT NULL,
    [compte_num]          VARCHAR (20)    NOT NULL,
    [libelle]             NVARCHAR (200)  NOT NULL,
    [debit]               DECIMAL (19, 2) DEFAULT ((0)) NOT NULL,
    [credit]              DECIMAL (19, 2) DEFAULT ((0)) NOT NULL,
    [saisi_par]           NVARCHAR (200)  NOT NULL,
    [saisi_le]            DATETIME2 (3)   DEFAULT (sysutcdatetime()) NOT NULL,
    [question_id]         INT             NULL,
    [code_tiers]          VARCHAR (20)    NULL,
    [reference]           VARCHAR (50)    NULL,
    [code_actif]          VARCHAR (20)    NULL,
    [feuille_question_id] INT             NULL,
    CONSTRAINT [pk_ecriture_brouillon] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_eb_montants] CHECK ([debit]>=(0) AND [credit]>=(0) AND ([debit]=(0) OR [credit]=(0))),
    CONSTRAINT [fk_eb_actif] FOREIGN KEY ([code_actif]) REFERENCES [dbo].[actif] ([code]),
    CONSTRAINT [fk_eb_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_eb_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_eb_feuille] FOREIGN KEY ([feuille_cote]) REFERENCES [dbo].[feuille_travail] ([cote]),
    CONSTRAINT [fk_eb_feuille_question] FOREIGN KEY ([feuille_question_id]) REFERENCES [dbo].[feuille_question] ([id]),
    CONSTRAINT [fk_eb_question] FOREIGN KEY ([question_id]) REFERENCES [dbo].[ref_question] ([id])
);


GO

