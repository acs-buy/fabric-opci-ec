
-- --- 2 : le DIP ne se prepare qu'a la fin du premier semestre ----------
CREATE   PROCEDURE dbo.pr_preparer_dip
    @entite      VARCHAR (20),
    @arrete      VARCHAR (20),
    @etabli_au   VARCHAR (30),
    @prepare_par NVARCHAR (200),
    @publie_site SMALLINT = 1,
    @motif_non_publication NVARCHAR (400) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @type VARCHAR (14), @exercice VARCHAR (20), @date_arrete DATE;
    SELECT @type = type_arrete, @exercice = exercice, @date_arrete = date_arrete
    FROM dbo.arrete_mission
    WHERE entite = @entite AND arrete = @arrete;
    IF @type IS NULL
    BEGIN
        DECLARE @m0 NVARCHAR (2000) =
            N'Preparation refusee : aucun arrete ouvert sous ce code. '
          + N'Ouvrir l''arrete et lui donner sa nature avant l''etape 5.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_preparer_dip', @entite, @arrete, NULL, @m0, @prepare_par);
        THROW 50037, @m0, 1;
    END;
    IF @exercice IS NULL
    BEGIN
        DECLARE @m0b NVARCHAR (2000) =
            N'Preparation refusee : l''arrete ' + @arrete + N' ne nomme pas '
          + N'son exercice de rattachement.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_preparer_dip', @entite, @arrete, NULL, @m0b, @prepare_par);
        THROW 50037, @m0b, 1;
    END;
    -- La seule nature qui porte le DIP.
    IF @type <> 'SEMESTRIEL'
    BEGIN
        DECLARE @m1 NVARCHAR (2000) =
            N'Preparation refusee : le document d''information periodique est '
          + N'le rapport semestriel, etabli a la fin de chaque premier '
          + N'semestre de l''exercice, article 28 I de l''instruction AMF '
          + N'DOC-2011-23. L''arrete ' + @arrete + N' est de nature ' + @type
          + CASE WHEN @type = 'ANNUEL'
                 THEN N' : une cloture annuelle porte le rapport annuel de '
                    + N'l''article 29, pas le document periodique.'
                 ELSE N' : il ne porte que la valeur liquidative.' END;
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_preparer_dip', @entite, @arrete, NULL, @m1, @prepare_par);
        THROW 50037, @m1, 1;
    END;
    -- Rubrique 3 de l'article 28 V : la valeur nette d'inventaire par part.
    IF NOT EXISTS (SELECT 1 FROM dbo.publication_vl
                   WHERE entite = @entite AND arrete = @arrete)
    BEGIN
        DECLARE @m2 NVARCHAR (2000) =
            N'Preparation refusee : la valeur liquidative de l''arrete '
          + @arrete + N' n''est pas publiee. Le document reprend la valeur '
          + N'nette d''inventaire par part, rubrique 3 de l''article 28 V.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_preparer_dip', @entite, @arrete, NULL, @m2, @prepare_par);
        THROW 50037, @m2, 1;
    END;
    INSERT INTO dbo.dip
        (entite, arrete, exercice, etabli_au, prepare_par,
         publie_site, motif_non_publication, date_arrete)
    VALUES (@entite, @arrete, @exercice, @etabli_au, @prepare_par,
            @publie_site, @motif_non_publication,
            COALESCE(@date_arrete, TRY_CAST(@arrete AS DATE)));
END;

GO

