CREATE TABLE [dbo].[decision_distribution] (
    [entite]              VARCHAR (20)    NOT NULL,
    [exercice]            VARCHAR (20)    NOT NULL,
    [categorie]           VARCHAR (30)    NOT NULL,
    [obligation_minimale] DECIMAL (19, 2) NOT NULL,
    [total_distribuable]  DECIMAL (19, 2) NOT NULL,
    [montant_decide]      DECIMAL (19, 2) NOT NULL,
    [date_assemblee]      DATE            NULL,
    [decide_par]          NVARCHAR (400)  NOT NULL,
    [decide_le]           DATETIME2 (3)   NOT NULL,
    [message_ecran]       NVARCHAR (2000) NULL,
    [message_ecran_le]    DATETIME2 (3)   NULL,
    [message_ecran_pour]  NVARCHAR (200)  NULL,
    CONSTRAINT [pk_decision_distribution] PRIMARY KEY CLUSTERED ([entite] ASC, [exercice] ASC, [categorie] ASC),
    CONSTRAINT [ck_decision_bornes] CHECK ([montant_decide]>=[obligation_minimale] AND [montant_decide]<=[total_distribuable]),
    CONSTRAINT [fk_decision_categorie] FOREIGN KEY ([categorie]) REFERENCES [dbo].[ref_obligation_distribution] ([categorie])
);


GO

