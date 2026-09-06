CREATE TABLE [dbo].[revision_compte_courant] (
    [id]              INT             IDENTITY (1, 1) NOT NULL,
    [entite]          VARCHAR (20)    NOT NULL,
    [arrete]          VARCHAR (20)    NOT NULL,
    [entite_fille]    VARCHAR (20)    NOT NULL,
    [compte]          VARCHAR (20)    NOT NULL,
    [montant_nominal] DECIMAL (19, 2) NOT NULL,
    [montant_revise]  DECIMAL (19, 2) NOT NULL,
    [motif]           NVARCHAR (600)  NOT NULL,
    [saisi_par]       NVARCHAR (200)  NOT NULL,
    [saisi_le]        DATETIME2 (3)   DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [pk_revision_cc] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_rcc_baisse_seule] CHECK ([montant_revise]>=(0) AND [montant_revise]<=[montant_nominal]),
    CONSTRAINT [fk_rcc_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_rcc_compte] FOREIGN KEY ([compte]) REFERENCES [dbo].[ref_compte] ([compte]),
    CONSTRAINT [fk_rcc_fille] FOREIGN KEY ([entite_fille]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [uq_revision_cc] UNIQUE NONCLUSTERED ([entite] ASC, [arrete] ASC, [entite_fille] ASC, [compte] ASC)
);


GO


-- --- 6 : le verrou de la revision d'un compte courant, K3 -------------
-- La cascade de l'article 212-5 deprecie TOTALEMENT les comptes courants
-- quand la valeur de l'entite est negative. Une revision saisie par
-- ailleurs sur la meme filiale et le meme arrete se contredirait avec
-- elle : la base refuse plutot que de laisser 2 montants en concurrence.
CREATE   TRIGGER dbo.tr_revision_cc_apres_cascade
ON dbo.revision_compte_courant
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN dbo.v_cascade_212_5 c
          ON c.entite_mere = i.entite AND c.entite_fille = i.entite_fille
         AND c.arrete = i.arrete
        WHERE c.valeur_comptable_compte_courant <> 0
          AND c.difference_estimation_compte_courant <> 0
    )
    BEGIN
        THROW 50047, 'Revision refusee : la cascade de l''article 212-5 deprecie deja totalement le compte courant de cette filiale a cet arrete, la valeur de l''entite etant negative. Deux montants ne se disputent pas la meme creance. Lire dbo.v_cascade_212_5 pour le detail de la cascade.', 1;
    END
END

GO

