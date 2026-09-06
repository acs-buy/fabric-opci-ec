CREATE TABLE [dbo].[ref_croisee] (
    [id]         INT            IDENTITY (1, 1) NOT NULL,
    [arrete]     VARCHAR (20)   NOT NULL,
    [entite]     VARCHAR (20)   NOT NULL,
    [compte_num] VARCHAR (20)   NOT NULL,
    [xref]       VARCHAR (30)   NULL,
    [etat]       VARCHAR (20)   DEFAULT ('A_FAIRE') NOT NULL,
    [par]        NVARCHAR (200) NULL,
    [date_etat]  DATETIME2 (3)  NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_ref_croisee_etat] CHECK ([etat]='CONCLUE' OR [etat]='EN_COURS' OR [etat]='A_FAIRE'),
    CONSTRAINT [ck_ref_croisee_par_si_conclue] CHECK ([etat]<>'CONCLUE' OR [par] IS NOT NULL AND [date_etat] IS NOT NULL),
    CONSTRAINT [ck_ref_croisee_xref_si_conclue] CHECK ([etat]<>'CONCLUE' OR [xref] IS NOT NULL),
    CONSTRAINT [fk_ref_croisee_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_ref_croisee_compte] FOREIGN KEY ([compte_num]) REFERENCES [dbo].[ref_compte] ([compte]),
    CONSTRAINT [fk_ref_croisee_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_ref_croisee_feuille] FOREIGN KEY ([xref], [arrete], [entite]) REFERENCES [dbo].[feuille_travail] ([cote], [arrete], [entite]),
    CONSTRAINT [uq_ref_croisee] UNIQUE NONCLUSTERED ([arrete] ASC, [entite] ASC, [compte_num] ASC)
);


GO

CREATE NONCLUSTERED INDEX [ix_ref_croisee_arrete]
    ON [dbo].[ref_croisee]([arrete] ASC, [entite] ASC);


GO

