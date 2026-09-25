CREATE TABLE [dbo].[attestation] (
    [id]               INT            IDENTITY (1, 1) NOT NULL,
    [entite]           VARCHAR (20)   NOT NULL,
    [arrete]           VARCHAR (20)   NOT NULL,
    [forme]            VARCHAR (20)   NOT NULL,
    [produit_par]      NVARCHAR (400) NULL,
    [produit_le]       DATETIME2 (3)  DEFAULT (sysutcdatetime()) NULL,
    [forme_proposee]   VARCHAR (20)   NULL,
    [arretee_par]      NVARCHAR (400) NULL,
    [arretee_le]       DATETIME2 (3)  NULL,
    [motif_limitation] NVARCHAR (800) NULL,
    CONSTRAINT [pk_attestation] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_attestation_forme] CHECK ([forme]='IMPOSSIBILITE' OR [forme]='AVEC_OBSERVATION' OR [forme]='SANS_OBSERVATION'),
    CONSTRAINT [ck_attestation_produite] CHECK ([produit_par] IS NULL AND [produit_le] IS NULL OR [produit_par] IS NOT NULL AND [produit_le] IS NOT NULL),
    CONSTRAINT [fk_attestation_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_attestation_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [uq_attestation] UNIQUE NONCLUSTERED ([entite] ASC, [arrete] ASC)
);


GO



-- --- 2 : le verrou de l'attestation, refait -------------------------
-- 50033 : le dossier ne boucle pas. Les feuilles non conclues n'en font
--         plus partie.
CREATE   TRIGGER dbo.tr_attestation_bouclage
ON dbo.attestation
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @entite VARCHAR (20), @arrete VARCHAR (20), @forme VARCHAR (20);
    SELECT TOP 1 @entite = entite, @arrete = arrete, @forme = forme
    FROM inserted;

    -- LES FEUILLES NON CONCLUES NE BLOQUENT PLUS. Une limitation des
    -- diligences se conclut, elle n'interdit pas de conclure : NP 2300
    -- paragraphes 20 et 21.
    DECLARE @restes NVARCHAR (1200) =
        (SELECT STRING_AGG(CAST(x.reste AS NVARCHAR (80)), N' | ')
         FROM (
            SELECT TOP 10 N'lot non vise : ' + CAST(l.id AS NVARCHAR (20)) AS reste
            FROM dbo.lot_ecritures l
            WHERE l.entite = @entite AND l.arrete = @arrete
              AND l.statut = 'PROPOSE'
         ) AS x);
    IF @restes IS NOT NULL
    BEGIN
        DECLARE @m1 NVARCHAR (2000) =
            N'Attestation refusée : ' + @restes
            + N'. Un lot proposé peut encore changer les comptes attestés : '
            + N'le faire viser ou l''annuler, puis produire l''attestation.';
        THROW 50033, @m1, 1;
    END;

    -- SANS_OBSERVATION est interdit quand une derogation est active, et
    -- desormais aussi quand AUCUNE feuille de cycle n'est conclue : sans
    -- diligence, il n'y a pas d'assurance a donner.
    IF @forme = 'SANS_OBSERVATION'
       AND EXISTS (SELECT 1 FROM dbo.derogation g
                   WHERE g.entite = @entite AND g.arrete = @arrete
                     AND g.levee_le IS NULL)
        THROW 50033,
            N'Attestation refusée : une dérogation active existe pour cet arrêté, la forme sans observation est indisponible.',
            1;

    IF @forme = 'SANS_OBSERVATION'
       AND NOT EXISTS (SELECT 1 FROM dbo.feuille_travail f
                       WHERE f.entite = @entite AND f.arrete = @arrete
                         AND f.cycle IS NOT NULL
                         AND f.forme_conclusion IS NOT NULL)
        THROW 50033,
            N'Attestation refusée : aucune feuille de cycle n''est conclue pour cet arrêté, et la forme sans observation suppose des diligences menées. La NP 2300 traite ce cas aux paragraphes 20 et 21 : une limitation des diligences appelle une conclusion avec observation, ou un refus d''attester si les incidences sont d''une importance telle qu''un niveau d''assurance suffisant ne peut être obtenu.',
            1;
END;

GO

