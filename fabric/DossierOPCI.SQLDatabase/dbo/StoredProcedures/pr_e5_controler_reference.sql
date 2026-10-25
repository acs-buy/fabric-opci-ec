-- ------------------------------------------------------------------ la valeur d'une colonne a cle etrangere d'une colonne : une ligne de la table visee
-- ecran 5, lot 1, script 323 (61_DEPLOIEMENT/generer_e5_323_procedures_de_tenue.py)
CREATE   PROCEDURE dbo.pr_e5_controler_reference
    @table   VARCHAR (120),
    @colonne SYSNAME,
    @valeur  NVARCHAR (4000),
    @champ   NVARCHAR (128)
AS
BEGIN
    SET NOCOUNT ON;
    IF @valeur IS NULL RETURN;
    DECLARE @cible SYSNAME, @col_cible SYSNAME, @sql NVARCHAR (MAX), @n INT, @m NVARCHAR (2000);
    SELECT TOP (1) @cible = OBJECT_NAME(fk.referenced_object_id), @col_cible = rc.name
    FROM sys.foreign_keys fk
    JOIN sys.foreign_key_columns fc ON fc.constraint_object_id = fk.object_id
    JOIN sys.columns pc ON pc.object_id = fc.parent_object_id AND pc.column_id = fc.parent_column_id
    JOIN sys.columns rc ON rc.object_id = fc.referenced_object_id AND rc.column_id = fc.referenced_column_id
    WHERE fk.parent_object_id = OBJECT_ID(N'dbo.' + QUOTENAME(@table)) AND pc.name = @colonne
      AND NOT EXISTS (SELECT 1 FROM sys.foreign_key_columns f2 WHERE f2.constraint_object_id = fk.object_id AND f2.constraint_column_id > 1);
    IF @cible IS NULL RETURN;
    SET @sql = N'SELECT @n = COUNT(*) FROM dbo.' + QUOTENAME(@cible) + N' AS x WHERE x.' + QUOTENAME(@col_cible)
             + N' = TRY_CAST(@v AS ' + dbo.fn_e5_type_colonne(@cible, @col_cible) + N');';
    EXEC sp_executesql @sql, N'@v NVARCHAR (4000), @n INT OUTPUT', @valeur, @n = @n OUTPUT;
    IF @n = 0
    BEGIN
        SET @m = N'« ' + @champ + N' » : « ' + @valeur + N' » n’est pas une ligne du référentiel « ' + dbo.fn_e5_libelle_referentiel(@cible) + N' ».';
        EXEC dbo.pr_e5_refuser 50851, @m;
    END;
END;

GO

