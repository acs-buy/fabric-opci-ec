CREATE TABLE [dbo].[attestation] (
    [id]                                 INT            IDENTITY (1, 1) NOT NULL,
    [entite]                             VARCHAR (20)   NOT NULL,
    [arrete]                             VARCHAR (20)   NOT NULL,
    [forme]                              VARCHAR (20)   NOT NULL,
    [produit_par]                        NVARCHAR (400) NULL,
    [produit_le]                         DATETIME2 (3)  DEFAULT (sysutcdatetime()) NULL,
    [forme_proposee]                     VARCHAR (20)   NULL,
    [arretee_par]                        NVARCHAR (400) NULL,
    [arretee_le]                         DATETIME2 (3)  NULL,
    [motif_limitation]                   NVARCHAR (800) NULL,
    [motif_considerations_particulieres] NVARCHAR (800) NULL,
    CONSTRAINT [pk_attestation] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_attestation_forme] CHECK ([forme]='IMPOSSIBILITE' OR [forme]='AVEC_OBSERVATION' OR [forme]='SANS_OBSERVATION' OR [forme]='COMPTE_RENDU_TRAVAUX'),
    CONSTRAINT [ck_attestation_forme_proposee] CHECK ([forme_proposee] IS NULL OR ([forme_proposee]='IMPOSSIBILITE' OR [forme_proposee]='AVEC_OBSERVATION' OR [forme_proposee]='SANS_OBSERVATION' OR [forme_proposee]='COMPTE_RENDU_TRAVAUX')),
    CONSTRAINT [ck_attestation_produite] CHECK ([produit_par] IS NULL AND [produit_le] IS NULL OR [produit_par] IS NOT NULL AND [produit_le] IS NOT NULL),
    CONSTRAINT [fk_attestation_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_attestation_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [uq_attestation] UNIQUE NONCLUSTERED ([entite] ASC, [arrete] ASC)
);


GO



-- 7. LE FILET, sur chaque ligne inseree ou mise a jour. Il juge une ligne inseree, et une ligne mise a jour dont la
-- forme ou le motif des considerations particulieres change, ou dont arretee_le recoit une valeur ; la remise a NULL de
-- la reouverture et l'ecriture de la production ne sont pas jugees.
CREATE   TRIGGER dbo.tr_attestation_bouclage
ON dbo.attestation
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @j TABLE (entite VARCHAR (20), arrete VARCHAR (20), forme VARCHAR (20), motif_cp NVARCHAR (800),
                      motif_limitation NVARCHAR (800), soumise BIT);
    INSERT @j
    SELECT i.entite, i.arrete, i.forme, NULLIF(LTRIM(RTRIM(i.motif_considerations_particulieres)), N''),
           NULLIF(LTRIM(RTRIM(i.motif_limitation)), N''),
           CASE WHEN e.soumise_commissariat_comptes = 1 THEN 1 ELSE 0 END
    FROM inserted i
    JOIN dbo.ref_entite e ON e.code = i.entite
    LEFT JOIN deleted d ON d.id = i.id
    WHERE d.id IS NULL
       OR ISNULL(i.forme, '') <> ISNULL(d.forme, '')
       OR ISNULL(i.motif_considerations_particulieres, N'') <> ISNULL(d.motif_considerations_particulieres, N'')
       OR (i.arretee_le IS NOT NULL AND (d.arretee_le IS NULL OR i.arretee_le <> d.arretee_le));
    IF NOT EXISTS (SELECT 1 FROM @j) RETURN;

    DECLARE @m NVARCHAR (2000), @entite VARCHAR (20);
    -- 50033 : un lot propose peut encore changer les comptes
    SELECT @m = STRING_AGG(CAST(x.reste AS NVARCHAR (80)), N' | ')
    FROM (SELECT TOP 10 N'lot non visé : ' + CAST(l.id AS NVARCHAR (20)) AS reste
          FROM dbo.lot_ecritures l JOIN @j j ON j.entite = l.entite AND j.arrete = l.arrete
          WHERE l.statut = 'PROPOSE') AS x;
    IF @m IS NOT NULL
    BEGIN
        SET @m = N'Rapport refusé : ' + @m + N'. Un lot proposé peut encore changer les comptes : le faire viser ou l''annuler, puis arrêter la forme du rapport de l''expert-comptable.';
        THROW 50033, @m, 1;
    END;
    IF EXISTS (SELECT 1 FROM @j j JOIN dbo.derogation g ON g.entite = j.entite AND g.arrete = j.arrete AND g.levee_le IS NULL
               WHERE j.forme = 'SANS_OBSERVATION')
        THROW 50033, N'Forme refusée : une dérogation active existe pour cet arrêté, la forme sans observation est indisponible.', 1;
    IF EXISTS (SELECT 1 FROM @j j WHERE j.forme = 'SANS_OBSERVATION'
               AND NOT EXISTS (SELECT 1 FROM dbo.feuille_travail f WHERE f.entite = j.entite AND f.arrete = j.arrete
                               AND f.cycle IS NOT NULL AND f.forme_conclusion IS NOT NULL))
        THROW 50033, N'Forme refusée : aucune feuille de cycle n''est conclue pour cet arrêté, et la forme sans observation suppose des diligences menées. La NP 2300 traite ce cas aux paragraphes 20 et 21 : une limitation des diligences appelle une conclusion avec observation, ou un refus d''attester si les incidences sont d''une importance telle qu''un niveau d''assurance suffisant ne peut être obtenu.', 1;
    -- les regles de forme selon l'entite
    SELECT TOP (1) @entite = entite FROM @j WHERE soumise = 1 AND forme <> 'COMPTE_RENDU_TRAVAUX' AND motif_cp IS NULL;
    IF @entite IS NOT NULL
    BEGIN
        SET @m = N'Forme refusée : l''entité ' + @entite + N' est soumise au commissariat aux comptes ; son rapport est un compte rendu de travaux (NP 2300, A10). Une attestation n''y est admise qu''avec le motif des considérations particulières qui la justifient.';
        THROW 50628, @m, 1;
    END;
    IF EXISTS (SELECT 1 FROM @j WHERE (motif_cp IS NOT NULL AND (forme = 'COMPTE_RENDU_TRAVAUX' OR soumise = 0))
                                   OR (forme = 'COMPTE_RENDU_TRAVAUX' AND motif_limitation IS NOT NULL))
        THROW 50629, N'Forme refusée : un motif de considérations particulières ne se saisit qu''avec une attestation, pour une entité soumise au commissariat aux comptes ; le compte rendu de travaux ne porte aucun motif.', 1;
    SET @entite = NULL;
    SELECT TOP (1) @entite = entite FROM @j WHERE forme = 'COMPTE_RENDU_TRAVAUX' AND soumise = 0;
    IF @entite IS NOT NULL
    BEGIN
        SET @m = N'Forme refusée : le compte rendu de travaux est réservé à une entité soumise au commissariat aux comptes ; pour l''entité ' + @entite + N', cet indicateur est à 0 ou à remplir.';
        THROW 50631, @m, 1;
    END;
END;

GO

