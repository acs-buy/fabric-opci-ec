-- 50090 : le montant decide sort des bornes.
-- 50091 : la mise en paiement doit avoir lieu dans le mois qui suit
--         l'assemblee, article L. 214-69, IV.
CREATE   PROCEDURE dbo.pr_decider_distribution
    @entite    VARCHAR (20),
    @exercice  VARCHAR (20),
    @categorie VARCHAR (30),
    @montant   DECIMAL (19,2),
    @assemblee DATE = NULL,
    @par       NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mini DECIMAL (19,2), @total DECIMAL (19,2), @taux DECIMAL (9,4);
    SELECT @taux = o.taux FROM dbo.ref_obligation_distribution o
    WHERE o.categorie = @categorie;
    IF @taux IS NULL
        THROW 50090,
            N'Décision refusée : cette catégorie de sommes distribuables n''est pas au référentiel. Les 3 catégories de l''article L. 214-69 sont le résultat, les plus-values et les produits de sociétés exonérées.',
            1;

    SELECT @total = CASE WHEN @categorie = 'PLUS_VALUES'
                         THEN s.plus_values_distribuables
                         ELSE s.resultat_distribuable END
    FROM dbo.v_sommes_distribuables s
    WHERE s.entite = @entite AND s.arrete = @exercice;

    IF @total IS NULL
        THROW 50090,
            N'Décision refusée : les sommes distribuables ne sont pas calculables pour cet exercice. Vérifier que les lots sont validés.',
            1;

    SET @mini = CAST(@total * @taux AS DECIMAL (19,2));

    IF @montant < @mini OR @montant > @total
    BEGIN
        DECLARE @m90 NVARCHAR (2000) =
            N'Décision refusée : le montant de '
            + FORMAT(@montant, 'N2', 'fr-FR')
            + N' sort des bornes. L''obligation minimale est de '
            + FORMAT(@mini, 'N2', 'fr-FR') + N', soit '
            + FORMAT(@taux, 'P2', 'fr-FR')
            + N' des sommes distribuables, et le total distribuable est de '
            + FORMAT(@total, 'N2', 'fr-FR') + N'. Article L. 214-69, II.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, message, geste, refuse_pour, refuse_le)
        VALUES ('pr_decider_distribution', @entite, @exercice, @m90,
                N'Saisir un montant compris entre l''obligation minimale et le total distribuable.',
                @par, SYSUTCDATETIME());
        THROW 50090, @m90, 1;
    END;

    IF EXISTS (SELECT 1 FROM dbo.decision_distribution
               WHERE entite = @entite AND exercice = @exercice
                 AND categorie = @categorie)
        UPDATE dbo.decision_distribution
        SET obligation_minimale = @mini, total_distribuable = @total,
            montant_decide = @montant, date_assemblee = @assemblee,
            decide_par = @par, decide_le = SYSUTCDATETIME()
        WHERE entite = @entite AND exercice = @exercice
          AND categorie = @categorie;
    ELSE
        INSERT INTO dbo.decision_distribution
            (entite, exercice, categorie, obligation_minimale,
             total_distribuable, montant_decide, date_assemblee, decide_par,
             decide_le)
        VALUES (@entite, @exercice, @categorie, @mini, @total, @montant,
                @assemblee, @par, SYSUTCDATETIME());
END;

GO

