-- : la 1re table, dans l'ordre des noms, qui porte une ligne de @code hors des tables purgees par la
-- suppression d'une filiale ; @trouve = son libelle, NULL sinon. Catalogue lu a chaque appel.
CREATE   PROCEDURE dbo.pr_entite_porte_donnees
    @code    VARCHAR (20),
    @trouve  NVARCHAR (128) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @q NVARCHAR (MAX), @w NVARCHAR (128);
    SET @trouve = NULL;
    SELECT @q = STRING_AGG(CAST(N'SELECT N''' + REPLACE(tb.name, N'''', N'''''') + N''' AS w FROM '
                                + QUOTENAME(SCHEMA_NAME(tb.schema_id)) + N'.' + QUOTENAME(tb.name) + N' WHERE '
                                + QUOTENAME(pc.name) + N' = @c' AS NVARCHAR (MAX)), N' UNION ALL ')
    FROM sys.foreign_keys fk
    JOIN sys.tables tb ON tb.object_id = fk.parent_object_id
    JOIN sys.foreign_key_columns k ON k.constraint_object_id = fk.object_id
    JOIN sys.columns pc ON pc.object_id = k.parent_object_id AND pc.column_id = k.parent_column_id
    WHERE fk.referenced_object_id = OBJECT_ID('dbo.ref_entite')
      AND (SELECT COUNT(*) FROM sys.foreign_key_columns k2 WHERE k2.constraint_object_id = fk.object_id) = 1
      AND tb.name NOT IN (N'ref_arrete', N'role_mission', N'demande_espace_client')
      AND NOT (tb.name = N'eligibilite_participation' AND pc.name = N'entite_fille');
    IF @q IS NULL RETURN;
    SET @q = N'SELECT TOP (1) @w = z.w FROM (' + @q + N') z ORDER BY z.w;';
    EXEC sys.sp_executesql @q, N'@c VARCHAR (20), @w NVARCHAR (128) OUTPUT', @c = @code, @w = @w OUTPUT;
    IF @w IS NOT NULL SET @trouve = dbo.fn_libelle_travail(@w);
END;

GO

