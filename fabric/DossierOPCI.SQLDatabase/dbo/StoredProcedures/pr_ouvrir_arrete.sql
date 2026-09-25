
-- --- 3-bis : ouvrir un arrete, avec son exercice et sa date -------------
-- La procedure de 55_journal_refus_et_procedures est reprise ici : sans
-- l'exercice, l'index d'unicite du bloc 3 ne sait pas a quel exercice
-- rattacher la cloture annuelle.
CREATE   PROCEDURE dbo.pr_ouvrir_arrete
    @entite      VARCHAR (20),
    @arrete      VARCHAR (20),
    @type_arrete VARCHAR (14),
    @par         NVARCHAR (200),
    @exercice    VARCHAR (20) = NULL,
    @date_arrete DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- Une cloture annuelle est a elle-meme son exercice. Tout autre arrete
    -- doit dire a quel exercice il se rattache : le code de la cloture
    -- annuelle de cet exercice.
    DECLARE @ex VARCHAR (20) = COALESCE(@exercice,
        CASE WHEN @type_arrete = 'ANNUEL' THEN @arrete END);
    IF @ex IS NULL
    BEGIN
        DECLARE @me NVARCHAR (2000) =
            N'Ouverture refusee : un arrete de nature ' + @type_arrete
          + N' doit nommer l''exercice auquel il se rattache, par le code '
          + N'de la cloture annuelle de cet exercice.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, message, refuse_pour)
        VALUES ('pr_ouvrir_arrete', @entite, @arrete, @me, @par);
        THROW 50038, @me, 1;
    END;
    BEGIN TRY
        INSERT INTO dbo.arrete_mission
            (entite, arrete, type_arrete, ouvert_par, exercice, date_arrete)
        VALUES (@entite, @arrete, @type_arrete, @par, @ex,
                COALESCE(@date_arrete, TRY_CAST(@arrete AS DATE)));
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, message, refuse_pour)
        VALUES ('pr_ouvrir_arrete', @entite, @arrete,
                LEFT(ERROR_MESSAGE(), 2000), @par);
        THROW;
    END CATCH;
END;

GO

