
-- ------------------------------------------------------------------ n° 6 : l'enveloppe d'ecran du visa d'une categorie
-- Refuse d'abord, avant tout appel : categorie vide, decision hors VISE et RENVOYE, renvoi sans motif ; puis appelle la
-- reprise n° 5, dont les 5 refus 50036 remontent tels quels.
CREATE   PROCEDURE dbo.pr_ecran_viser_obligation_distribution
    @entite    VARCHAR (20),
    @arrete    VARCHAR (20),
    @categorie NVARCHAR (300),
    @decision  VARCHAR (10),
    @motif     NVARCHAR (600) = NULL,
    @vise_par  NVARCHAR (200)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    -- 15/10/2026 : une personne vide ou NULL se refuse en francais, avant tout le reste
    IF NULLIF(LTRIM(RTRIM(@vise_par)), N'') IS NULL
        THROW 50824, N'Visa refusé : votre compte ne tient pas, sur ce dossier, le rôle d''associé signataire qui vise la catégorie.', 1;
    DECLARE @m NVARCHAR (1000);
    SET @categorie = NULLIF(LTRIM(RTRIM(@categorie)), N'');
    IF @categorie IS NULL
        THROW 50820, N'Choisissez la catégorie dans la liste « Catégorie ».', 1;
    SET @decision = UPPER(LTRIM(RTRIM(@decision)));
    IF ISNULL(@decision, '') NOT IN ('VISE', 'RENVOYE')
        THROW 50821, N'La décision est « VISE » ou « RENVOYE ».', 1;
    SET @motif = NULLIF(LTRIM(RTRIM(@motif)), N'');
    IF @decision = 'RENVOYE' AND @motif IS NULL
        THROW 50822, N'Le motif du renvoi est obligatoire : il dit au préparateur ce qui est à reprendre.', 1;
    DECLARE @cat VARCHAR (20) = dbo.fn_e4_categorie(@categorie);
    IF @cat IS NULL
    BEGIN
        SET @m = N'La catégorie « ' + REPLACE(@categorie, N'%', N'%%') + N' » n''est pas une catégorie de l''obligation de distribution.';
        THROW 50823, @m, 1;
    END;
    EXEC dbo.pr_viser_obligation_distribution @entite = @entite, @exercice = @arrete, @categorie = @cat, @decision = @decision,
         @motif = @motif, @vise_par = @vise_par;
    SELECT @entite AS vehicule,
           N'Catégorie ' + CASE @decision WHEN 'VISE' THEN N'visée' ELSE N'renvoyée au préparateur' END
           + N' pour l''exercice clos le ' + dbo.fn_date_ecran(@arrete) + N'.' AS message;
END;

GO

