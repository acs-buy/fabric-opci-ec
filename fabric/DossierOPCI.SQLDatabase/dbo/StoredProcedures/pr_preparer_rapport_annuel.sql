
-- --- 4 : preparer le rapport annuel, garde par la nature de l'arrete ---
CREATE   PROCEDURE dbo.pr_preparer_rapport_annuel
    @entite      VARCHAR (20),
    @arrete      VARCHAR (20),
    @arrete_au   VARCHAR (30),
    @prepare_par NVARCHAR (200),
    @rapport_gestion      SMALLINT = 0,
    @documents_synthese   SMALLINT = 0,
    @certification_cac    SMALLINT = 0,
    @rapport_conseil_fpi  SMALLINT = NULL,
    @changements_substantiels NVARCHAR (1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @type VARCHAR (14), @exercice VARCHAR (20);
    SELECT @type = type_arrete, @exercice = exercice
    FROM dbo.arrete_mission
    WHERE entite = @entite AND arrete = @arrete;
    IF @type IS NULL OR @type <> 'ANNUEL'
    BEGIN
        DECLARE @m1 NVARCHAR (2000) =
            N'Preparation refusee : le rapport annuel est arrete le dernier '
          + N'jour de l''exercice ou a la derniere valeur liquidative '
          + N'publiee, article 29 de l''instruction AMF DOC-2011-23. '
          + COALESCE(N'L''arrete ' + @arrete + N' est de nature '
                     + @type + N'.', N'Aucun arrete ouvert sous ce code.');
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_preparer_rapport_annuel', @entite, @arrete, NULL, @m1, @prepare_par);
        THROW 50039, @m1, 1;
    END;
    -- Les documents de synthese portent la certification : sans elle, le
    -- rapport n'est pas celui que l'article 29 decrit.
    IF @documents_synthese = 1 AND @certification_cac = 0
    BEGIN
        DECLARE @m2 NVARCHAR (2000) =
            N'Preparation refusee : les documents de synthese doivent '
          + N'comporter la certification delivree par le commissaire aux '
          + N'comptes, article 29 de l''instruction AMF DOC-2011-23.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_preparer_rapport_annuel', @entite, @arrete, NULL, @m2, @prepare_par);
        THROW 50039, @m2, 1;
    END;
    IF NOT EXISTS (SELECT 1 FROM dbo.publication_vl
                   WHERE entite = @entite AND arrete = @arrete)
    BEGIN
        DECLARE @m3 NVARCHAR (2000) =
            N'Preparation refusee : la valeur liquidative de la cloture '
          + @arrete + N' n''est pas publiee.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_preparer_rapport_annuel', @entite, @arrete, NULL, @m3, @prepare_par);
        THROW 50039, @m3, 1;
    END;
    INSERT INTO dbo.rapport_annuel
        (entite, arrete, exercice, arrete_au, rapport_gestion,
         documents_synthese, certification_cac, rapport_conseil_fpi,
         changements_substantiels, prepare_par)
    VALUES (@entite, @arrete, @exercice, @arrete_au, @rapport_gestion,
            @documents_synthese, @certification_cac, @rapport_conseil_fpi,
            @changements_substantiels, @prepare_par);
END;

GO

