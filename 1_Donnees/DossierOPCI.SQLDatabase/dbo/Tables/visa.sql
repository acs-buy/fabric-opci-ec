CREATE TABLE [dbo].[visa] (
    [id]          INT            IDENTITY (1, 1) NOT NULL,
    [nature]      VARCHAR (12)   NOT NULL,
    [objet_ref]   VARCHAR (30)   NOT NULL,
    [entite]      VARCHAR (20)   NOT NULL,
    [arrete]      VARCHAR (20)   NOT NULL,
    [cycle]       VARCHAR (10)   NULL,
    [decision]    VARCHAR (8)    NOT NULL,
    [motif]       NVARCHAR (600) NULL,
    [propose_par] NVARCHAR (200) NOT NULL,
    [decide_par]  NVARCHAR (200) NOT NULL,
    [decide_le]   DATETIME2 (3)  DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [pk_visa] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_visa_decision] CHECK ([decision]='RENVOYE' OR [decision]='VISE'),
    CONSTRAINT [ck_visa_motif_au_renvoi] CHECK ([decision]='VISE' OR [motif] IS NOT NULL),
    CONSTRAINT [ck_visa_nature] CHECK ([nature]='CLOTURE' OR [nature]='SYNTHESE' OR [nature]='MAINTIEN' OR [nature]='ACCEPTATION' OR [nature]='OBLIGATION' OR [nature]='PUBLICATION' OR [nature]='EVALUATION' OR [nature]='DEROGATION' OR [nature]='CONCLUSION' OR [nature]='LOT'),
    CONSTRAINT [ck_visa_roles_separes] CHECK ([propose_par]<>[decide_par]),
    CONSTRAINT [fk_visa_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete])
);


GO

CREATE NONCLUSTERED INDEX [ix_visa_arrete]
    ON [dbo].[visa]([entite] ASC, [arrete] ASC, [cycle] ASC);


GO

CREATE NONCLUSTERED INDEX [ix_visa_objet]
    ON [dbo].[visa]([nature] ASC, [objet_ref] ASC);


GO


-- --- 8 : le verrou, un lot perime ne se vise pas sans le savoir ------
-- Il ne refuse pas le visa : il refuse le visa SILENCIEUX. Viser un lot
-- perime exige un motif, ce qui oblige le chef de mission a dire pourquoi
-- il passe outre. C'est la trace que la supervision doit porter.
CREATE   TRIGGER dbo.tr_visa_lot_perime
ON dbo.visa
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN dbo.lot_ecritures l ON l.id = TRY_CAST(i.objet_ref AS INT)
        WHERE i.nature = 'LOT' AND i.decision = 'VISE'
          AND l.perime_le IS NOT NULL
          AND i.motif IS NULL
    )
        THROW 50060, 'Visa refuse : ce lot est marque perime, son perimetre ayant change apres sa generation. Le viser exige un motif disant pourquoi la generation n''est pas reprise. Lire dbo.v_lot_perime pour le fait qui l''a perime.', 1;
END

GO


-- --- E8 : le verrou lit la nature ----------------------------------
CREATE   TRIGGER dbo.tr_visa_separation_des_roles
ON dbo.visa
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM inserted i
        WHERE dbo.fn_proposant(i.nature, i.objet_ref) IS NOT NULL
          AND dbo.fn_proposant(i.nature, i.objet_ref) = i.decide_par
    )
        THROW 50050, 'Visa refuse : le decideur est celui qui a propose l''objet. Nul ne vise son propre travail, quelle que soit la nature de l''objet.', 1;

    -- Le role doit etre habilite POUR CETTE NATURE, et non habilite en
    -- general. Corrige le 04/09/2026, ecart E8 de la revue : le drapeau
    -- vise de dbo.ref_role laissait l'associe signataire viser une
    -- derogation, ce que le libelle de son role ne prevoit pas.
    IF EXISTS (
        SELECT 1 FROM inserted i
        WHERE dbo.fn_peut_viser_nature(i.entite, i.decide_par, i.nature,
                                       CAST(i.decide_le AS DATE)) = 0
    )
        THROW 50051, 'Visa refuse : le decideur ne tient sur cette entite, a la date de la decision, aucun role habilite a viser CETTE NATURE d''objet. Lire dbo.v_role_nature_visa pour la repartition.', 1;

    IF EXISTS (
        SELECT 1 FROM inserted i
        WHERE dbo.fn_proposant(i.nature, i.objet_ref) IS NOT NULL
          AND dbo.fn_proposant(i.nature, i.objet_ref) <> i.propose_par
    )
        THROW 50052, 'Visa refuse : le proposant porte par le visa n''est pas celui que la source de l''objet designe. Lire dbo.fn_proposant pour la valeur attendue.', 1;
END

GO

