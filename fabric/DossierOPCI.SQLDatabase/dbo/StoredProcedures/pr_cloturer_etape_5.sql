

-- --- 7 : O3, la cloture de l'etape 5 --------------------------------
-- 50087 : la valeur liquidative n'est pas publiee.
-- 50088 : a l'annuel, les 3 categories de sommes distribuables ne sont
--         pas toutes visees.
-- 50089 : la forme de l'attestation n'est pas arretee.
CREATE   PROCEDURE dbo.pr_cloturer_etape_5
    @entite VARCHAR (20),
    @arrete VARCHAR (20),
    @par    NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @nature VARCHAR (14) =
        (SELECT type_arrete FROM dbo.ref_arrete
         WHERE entite = @entite AND arrete = @arrete);

    IF NOT EXISTS (SELECT 1 FROM dbo.publication_vl p
                   WHERE p.entite = @entite AND p.arrete = @arrete)
        THROW 50087,
            N'Clôture refusée : la valeur liquidative de cet arrêté n''est pas publiée. L''étape 5 ne se ferme pas sur un arrêté dont la valeur liquidative n''est pas sortie.',
            1;

    -- A l'annuel seulement : les categories de sommes distribuables.
    IF @nature = 'ANNUEL'
    BEGIN
        DECLARE @non_visees INT =
            (SELECT COUNT(*) FROM dbo.obligation_distribution o
             WHERE o.entite = @entite
               AND YEAR(CONVERT(DATE, o.exercice)) = YEAR(CONVERT(DATE, @arrete))
               AND (o.etat IS NULL OR o.etat <> 'VISEE'));
        IF @non_visees > 0
        BEGIN
            DECLARE @m88 NVARCHAR (1200) =
                N'Clôture refusée : ' + CAST(@non_visees AS NVARCHAR (10))
                + N' catégorie(s) de sommes distribuables ne sont pas visées '
                + N'pour cet exercice. À l''arrêté annuel, les 3 catégories '
                + N'se visent avant la clôture.';
            THROW 50088, @m88, 1;
        END;
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.attestation a
                   WHERE a.entite = @entite AND a.arrete = @arrete
                     AND a.arretee_le IS NOT NULL)
        THROW 50089,
            N'Clôture refusée : la forme de l''attestation n''est pas arrêtée pour cet arrêté. L''associé signataire l''arrête avant la clôture.',
            1;

    DECLARE @ref VARCHAR (30) = @entite + '|' + @arrete;
    DECLARE @propose NVARCHAR (400) =
        (SELECT TOP 1 publie_par FROM dbo.publication_vl
         WHERE entite = @entite AND arrete = @arrete ORDER BY id DESC);

    EXEC dbo.pr_garde_visa 'CLOTURE', @ref, 'VISE', @par, NULL;

    INSERT INTO dbo.visa (nature, objet_ref, entite, arrete, cycle,
                          decision, propose_par, decide_par, decide_le)
    VALUES ('CLOTURE', @ref, @entite, @arrete, NULL, 'VISE', @propose, @par,
            SYSUTCDATETIME());
END;

GO

