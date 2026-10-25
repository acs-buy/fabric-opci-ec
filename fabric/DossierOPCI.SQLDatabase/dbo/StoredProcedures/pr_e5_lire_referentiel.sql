-- ------------------------------------------------------------------ le referentiel recu par sa table ou par son nom, et son mode de tenue (objet n° 1)
-- ecran 5, lot 1, script 323 (61_DEPLOIEMENT/generer_e5_323_procedures_de_tenue.py)
CREATE   PROCEDURE dbo.pr_e5_lire_referentiel
    @referentiel NVARCHAR (200),
    @table       VARCHAR (120)  OUTPUT,
    @libelle     NVARCHAR (160) OUTPUT,
    @mode        VARCHAR (5)    OUTPUT,
    @actions     TINYINT        OUTPUT,
    @propre      NVARCHAR (60)  OUTPUT,
    @designation VARCHAR (128)  OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @r NVARCHAR (200) = NULLIF(LTRIM(RTRIM(@referentiel)), N''), @du BIT, @m NVARCHAR (2000);
    SELECT @table = NULL, @libelle = NULL, @mode = NULL, @actions = NULL, @propre = NULL, @designation = NULL;
    IF @r IS NULL
        EXEC dbo.pr_e5_refuser 50831, N'Choisissez le référentiel dans la liste « Référentiel ».';
    SELECT TOP (1) @table = r.table_nom, @libelle = r.libelle, @mode = r.mode_tenue, @du = r.du_cabinet,
                   @actions = r.actions_de_ligne, @propre = NULLIF(r.action_propre, N''),
                   @designation = NULLIF(r.colonne_designation, '')
    FROM dbo.ref_referentiel r
    WHERE r.table_nom = @r OR r.libelle = @r
    ORDER BY CASE WHEN r.table_nom = @r THEN 0 ELSE 1 END;
    IF @table IS NULL
    BEGIN
        SET @m = N'Le référentiel « ' + @r + N' » n’est pas au registre des référentiels du cabinet.';
        EXEC dbo.pr_e5_refuser 50831, @m;
    END;
    IF ISNULL(@du, 0) = 0
    BEGIN
        SET @m = N'Action refusée : « ' + @libelle + N' » porte des données de dossier, qui se modifient depuis les écrans du dossier et non depuis les référentiels du cabinet.';
        EXEC dbo.pr_e5_refuser 50831, @m;
    END;
    IF OBJECT_ID(N'dbo.' + QUOTENAME(@table), N'U') IS NULL
    BEGIN
        SET @m = N'Action refusée : la table du référentiel « ' + @libelle + N' » est absente de la base.';
        EXEC dbo.pr_e5_refuser 50831, @m;
    END;
END;

GO

