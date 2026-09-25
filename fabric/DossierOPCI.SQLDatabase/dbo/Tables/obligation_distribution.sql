CREATE TABLE [dbo].[obligation_distribution] (
    [id]                      INT             IDENTITY (1, 1) NOT NULL,
    [entite]                  VARCHAR (20)    NOT NULL,
    [exercice]                VARCHAR (20)    NOT NULL,
    [categorie]               VARCHAR (20)    NOT NULL,
    [base_calcul]             DECIMAL (19, 2) NOT NULL,
    [taux]                    DECIMAL (5, 2)  NOT NULL,
    [montant]                 DECIMAL (19, 2) NOT NULL,
    [dont_indirect_n_moins_1] DECIMAL (19, 2) DEFAULT ((0)) NOT NULL,
    [source]                  NVARCHAR (400)  NOT NULL,
    [vise_par]                NVARCHAR (200)  NOT NULL,
    [vise_le]                 DATETIME2 (3)   DEFAULT (sysutcdatetime()) NOT NULL,
    [etat]                    VARCHAR (12)    NULL,
    [propose_par]             NVARCHAR (400)  NULL,
    [indirect_saisi_par]      NVARCHAR (400)  NULL,
    [message_ecran]           NVARCHAR (2000) NULL,
    [message_ecran_le]        DATETIME2 (3)   NULL,
    [message_ecran_pour]      NVARCHAR (200)  NULL,
    CONSTRAINT [pk_obligation_distribution] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_obligation_etat] CHECK ([etat]='RENVOYEE' OR [etat]='VISEE' OR [etat]='PROPOSEE'),
    CONSTRAINT [ck_od_categorie] CHECK ([categorie]='DIVIDENDES_SIIC_100' OR [categorie]='PLUS_VALUES_50' OR [categorie]='REVENUS_85'),
    CONSTRAINT [ck_od_montant] CHECK ([montant]=round(([base_calcul]*[taux])/(100),(2))),
    CONSTRAINT [ck_od_taux_par_categorie] CHECK ([categorie]='REVENUS_85' AND [taux]=(85) OR [categorie]='PLUS_VALUES_50' AND [taux]=(50) OR [categorie]='DIVIDENDES_SIIC_100' AND [taux]=(100)),
    CONSTRAINT [fk_od_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [uq_obligation] UNIQUE NONCLUSTERED ([entite] ASC, [exercice] ASC, [categorie] ASC)
);


GO

-- 50086 : le proposant de l'obligation ne peut pas etre l'associe qui a
--         publie la valeur liquidative de l'arrete.
CREATE   TRIGGER dbo.tr_obligation_proposant_distinct
ON dbo.obligation_distribution
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF CAST(ISNULL(SESSION_CONTEXT(N'semis'), 0) AS INT) = 1 RETURN;
    IF EXISTS (SELECT 1 FROM inserted i
               JOIN dbo.publication_vl p ON p.entite = i.entite
               WHERE i.propose_par IS NOT NULL
                 AND p.publie_par = i.propose_par
                 AND YEAR(CONVERT(DATE, p.arrete)) = YEAR(CONVERT(DATE, i.exercice)))
    BEGIN
        THROW 50086,
            N'Obligation refusée : celui qui propose l''obligation de distribution ne peut pas être l''associé qui a publié la valeur liquidative du même exercice. La distribution se propose par un autre, et l''associé la vise.',
            1;
    END;
END;

GO

