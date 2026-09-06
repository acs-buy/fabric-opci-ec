
-- --- E7 : l'obligation de distribution ecrit son visa --------------
-- Le commentaire du bloc 8 du script 80 affirmait que les 2 procedures
-- ecrivaient desormais dans dbo.visa. C'etait faux pour celle-ci : seule
-- pr_publier_vl avait ete refaite. L'affirmation est rectifiee par le
-- fait.
CREATE   PROCEDURE dbo.pr_viser_obligation_distribution
    @entite      VARCHAR (20),
    @exercice    VARCHAR (20),
    @categorie   VARCHAR (20),
    @base_calcul DECIMAL (19,2),
    @taux        DECIMAL (5,2),
    @source      NVARCHAR (400),
    @vise_par    NVARCHAR (200)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @arrete_annuel VARCHAR (20);
    SELECT @arrete_annuel = arrete FROM dbo.arrete_mission
    WHERE entite = @entite AND exercice = @exercice
      AND type_arrete = 'ANNUEL';
    BEGIN TRY
        IF @arrete_annuel IS NULL
        BEGIN
            DECLARE @m1 NVARCHAR (2000) =
                N'Visa refuse : les sommes distribuables sont celles de '
              + N'l''exercice, I de l''article L. 214-69 du code monetaire et '
              + N'financier. L''exercice ' + @exercice + N' ne porte aucune '
              + N'cloture annuelle ouverte : un arrete de valeur liquidative '
              + N'en cours d''annee ne calcule pas l''obligation.';
            THROW 50036, @m1, 1;
        END;
        IF NOT EXISTS (SELECT 1 FROM dbo.publication_vl
                       WHERE entite = @entite AND arrete = @arrete_annuel)
        BEGIN
            DECLARE @m2 NVARCHAR (2000) =
                N'Visa refuse : la valeur liquidative de la cloture annuelle '
              + @arrete_annuel + N' n''est pas publiee. L''obligation se '
              + N'calcule sur des comptes arretes.';
            THROW 50036, @m2, 1;
        END;

        DECLARE @montant DECIMAL (19,2) =
            CAST(@base_calcul * @taux / 100.0 AS DECIMAL (19,2));

        BEGIN TRANSACTION;
        INSERT INTO dbo.obligation_distribution
            (entite, exercice, categorie, base_calcul, taux, montant,
             dont_indirect_n_moins_1, source, vise_par, vise_le)
        VALUES (@entite, @exercice, @categorie, @base_calcul, @taux, @montant,
                0, @source, @vise_par, SYSUTCDATETIME());
        DECLARE @id INT = SCOPE_IDENTITY();

        -- Le visa, qui soumet la decision au verrou de separation des
        -- roles comme les 5 autres natures.
        DECLARE @ref VARCHAR (30) = CAST(@id AS VARCHAR (30));
        DECLARE @propose NVARCHAR (200) = dbo.fn_proposant('OBLIGATION', @ref);
        IF @propose IS NULL
            THROW 50036, 'Visa refuse : aucune publication de valeur liquidative ne porte cette entite, la base de calcul n''a donc pas de proposant identifiable.', 1;

        EXEC dbo.pr_garde_visa 'OBLIGATION', @ref, 'VISE', @vise_par, NULL;
        INSERT INTO dbo.visa (nature, objet_ref, entite, arrete, cycle,
                              decision, propose_par, decide_par)
        VALUES ('OBLIGATION', @ref, @entite, @arrete_annuel, NULL,
                'VISE', @propose, @vise_par);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, message, refuse_pour)
        VALUES ('pr_viser_obligation_distribution', @entite,
                COALESCE(@arrete_annuel, @exercice),
                LEFT(ERROR_MESSAGE(), 2000), @vise_par);
        THROW;
    END CATCH;
END

GO

