CREATE TABLE [dbo].[arrete_mission] (
    [id]          INT            IDENTITY (1, 1) NOT NULL,
    [entite]      VARCHAR (20)   NOT NULL,
    [arrete]      VARCHAR (20)   NOT NULL,
    [type_arrete] VARCHAR (14)   NOT NULL,
    [ouvert_par]  NVARCHAR (200) NOT NULL,
    [ouvert_le]   DATETIME2 (3)  DEFAULT (sysutcdatetime()) NOT NULL,
    [exercice]    VARCHAR (20)   NULL,
    [date_arrete] DATE           NULL,
    CONSTRAINT [pk_arrete_mission] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_am_type] CHECK ([type_arrete]='INTERMEDIAIRE' OR [type_arrete]='SEMESTRIEL' OR [type_arrete]='ANNUEL'),
    CONSTRAINT [fk_am_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_am_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_am_nature_arrete] FOREIGN KEY ([type_arrete]) REFERENCES [dbo].[ref_nature_arrete] ([code]),
    CONSTRAINT [uq_arrete_mission] UNIQUE NONCLUSTERED ([entite] ASC, [arrete] ASC)
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [ux_arrete_annuel]
    ON [dbo].[arrete_mission]([entite] ASC, [exercice] ASC) WHERE ([type_arrete]='ANNUEL');


GO

CREATE UNIQUE NONCLUSTERED INDEX [ux_arrete_semestriel]
    ON [dbo].[arrete_mission]([entite] ASC, [exercice] ASC) WHERE ([type_arrete]='SEMESTRIEL');


GO


-- --- 4 : la porte 1 n'exige l'expertise que la ou l'article la fonde ----
-- Seule la premiere requete change : elle ne balaie plus tous les actifs
-- du perimetre mais ceux dont la nature porte expertise_requise = 1.
-- Les portes 2 et 3 sont reprises a l'identique de
-- 47_portes_arrete_maintien.
CREATE   TRIGGER dbo.tr_arrete_portes
ON dbo.arrete_mission
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Porte 1 : un actif dont la nature exige une expertise, dans le
    -- perimetre de l'entite et de ses filiales, sans expertise a la date
    -- de l'arrete, ouvre le refus.
    DECLARE @sans_expertise NVARCHAR (1200) =
        (SELECT STRING_AGG(CAST(x.code AS NVARCHAR (24)), N', ')
         FROM (SELECT DISTINCT TOP 20 a.code
               FROM inserted i
               JOIN dbo.actif a
                 ON a.entite_detentrice = i.entite
                 OR a.entite_detentrice IN (SELECT d.entite_fille
                                            FROM dbo.detention d
                                            WHERE d.entite_mere = i.entite
                                              AND d.arrete = i.arrete)
               JOIN dbo.ref_nature_actif r
                 ON r.nature = a.nature
                AND r.expertise_requise = 1
               WHERE NOT EXISTS (SELECT 1 FROM dbo.expertise e
                                 WHERE e.code_actif = a.code
                                   AND e.date_valeur = i.arrete)
               ORDER BY a.code) AS x);
    IF @sans_expertise IS NOT NULL
    BEGIN
        DECLARE @m1 NVARCHAR (2000) =
            N'Ouverture refusee, porte 1 : expertise absente a la date de '
            + N'l''arrete pour les actifs du perimetre suivants : '
            + @sans_expertise
            + N'. Ces actifs se valorisent a la valeur actuelle par la valeur '
            + N'de marche, article 211-6. Deposer les rapports puis rouvrir.';
        THROW 50025, @m1, 1;
    END;

    -- Porte 1 : une filiale detenue sans balance validee a l'arrete
    -- (lot de famille IMPORTEE) ouvre le refus.
    DECLARE @sans_balance NVARCHAR (1200) =
        (SELECT STRING_AGG(CAST(x.entite_fille AS NVARCHAR (24)), N', ')
         FROM (SELECT DISTINCT TOP 20 d.entite_fille
               FROM inserted i
               JOIN dbo.detention d
                 ON d.entite_mere = i.entite
                AND d.arrete = i.arrete
               WHERE NOT EXISTS (SELECT 1 FROM dbo.lot_ecritures l
                                 WHERE l.entite = d.entite_fille
                                   AND l.arrete = i.arrete
                                   AND l.famille = 'IMPORTEE'
                                   AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE'))
               ORDER BY d.entite_fille) AS x);
    IF @sans_balance IS NOT NULL
    BEGIN
        DECLARE @m2 NVARCHAR (2000) =
            N'Ouverture refusee, porte 1 : aucune balance validee a l''arrete '
            + N'pour les filiales detenues suivantes : ' + @sans_balance
            + N'. Importer et valider leurs balances puis rouvrir.';
        THROW 50026, @m2, 1;
    END;

    -- Porte 3 : le dernier arrete annuel anterieur de l'entite doit porter
    -- un maintien approuve. Sans arrete annuel anterieur, la porte ne
    -- s'applique pas, l'acceptation repondant de l'ouverture.
    DECLARE @entite VARCHAR (20), @arrete VARCHAR (20), @dernier_annuel VARCHAR (20);
    SELECT TOP 1
        @entite = i.entite,
        @arrete = i.arrete,
        @dernier_annuel = da.dernier
    FROM inserted i
    CROSS APPLY (SELECT MAX(am.arrete) AS dernier
                 FROM dbo.arrete_mission am
                 WHERE am.entite = i.entite
                   AND am.type_arrete = 'ANNUEL'
                   AND am.arrete < i.arrete) da
    WHERE da.dernier IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM dbo.maintien_mission m
                      WHERE m.entite = i.entite
                        AND m.arrete_conclu = da.dernier
                        AND m.statut = 'APPROUVE');
    IF @dernier_annuel IS NOT NULL
    BEGIN
        DECLARE @m3 NVARCHAR (2000) =
            N'Ouverture refusee, porte 3 : le dernier arrete annuel anterieur ('
            + @dernier_annuel + N') de l''entite ' + @entite
            + N' ne porte pas de maintien de mission approuve. Le blocage se '
            + N'leve par l''approbation nominative du signataire, jamais par derogation.';
        THROW 50027, @m3, 1;
    END;
END;

GO

