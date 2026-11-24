-- --- 4. un arrete porte-t-il un travail, et lequel ----------------------------------------------------
-- 19/11/2026 : 1 si une ligne d'une table qui reference ref_arrete par (entite, arrete) vise cet arrete, ou si une
-- expertise d'un actif de l'entite porte sa date ; 0 sinon. Les tables se lisent au catalogue (sys.foreign_keys) : une
-- table ajoutee plus tard avec sa cle est couverte. Catalogue illisible : 1, par prudence. La cle etrangere reste le
-- dernier rempart : un DELETE d'un arrete reference echoue et annule tout.
-- @trouve rend le libelle du 1er travail trouve (ordre des noms de table), NULL sans travail ou catalogue illisible.
CREATE   PROCEDURE dbo.pr_arrete_porte_travail
    @entite  VARCHAR (20),
    @arrete  VARCHAR (20),
    @travail BIT OUTPUT,
    @trouve  NVARCHAR (128) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @q NVARCHAR (MAX), @n INT, @w NVARCHAR (128);
    SET @trouve = NULL;
    SELECT @n = COUNT(*),
           @q = STRING_AGG(CAST(N'SELECT N''' + REPLACE(tb.name, N'''', N'''''') + N''' AS w FROM '
                                + QUOTENAME(SCHEMA_NAME(tb.schema_id)) + N'.' + QUOTENAME(tb.name)
                                + N' WHERE ' + QUOTENAME(c.ce) + N' = @e AND ' + QUOTENAME(c.ca) + N' = @a' AS NVARCHAR (MAX)),
                           N' UNION ALL ')
    FROM sys.foreign_keys fk
    JOIN sys.tables tb ON tb.object_id = fk.parent_object_id
    -- aucun agregat ne voit de NULL (avertissement 8153 lu seul par pyodbc avant le THROW qui suit)
    CROSS APPLY (SELECT (SELECT TOP (1) pc.name
                         FROM sys.foreign_key_columns k
                         JOIN sys.columns pc ON pc.object_id = k.parent_object_id AND pc.column_id = k.parent_column_id
                         JOIN sys.columns rc ON rc.object_id = k.referenced_object_id AND rc.column_id = k.referenced_column_id
                         WHERE k.constraint_object_id = fk.object_id AND rc.name = 'entite') AS ce,
                        (SELECT TOP (1) pc.name
                         FROM sys.foreign_key_columns k
                         JOIN sys.columns pc ON pc.object_id = k.parent_object_id AND pc.column_id = k.parent_column_id
                         JOIN sys.columns rc ON rc.object_id = k.referenced_object_id AND rc.column_id = k.referenced_column_id
                         WHERE k.constraint_object_id = fk.object_id AND rc.name = 'arrete') AS ca) c
    WHERE fk.referenced_object_id = OBJECT_ID('dbo.ref_arrete')
      AND fk.parent_object_id <> OBJECT_ID('dbo.ref_arrete')
      AND c.ce IS NOT NULL AND c.ca IS NOT NULL;
    SET @travail = 1;
    IF ISNULL(@n, 0) = 0 OR @q IS NULL RETURN;
    SET @q = N'SELECT TOP (1) @w = z.w FROM (' + @q + N') z ORDER BY z.w;';
    EXEC sys.sp_executesql @q, N'@e VARCHAR (20), @a VARCHAR (20), @w NVARCHAR (128) OUTPUT', @e = @entite, @a = @arrete, @w = @w OUTPUT;
    -- l'expertise d'un actif de l'entite ou de ses filiales a cet arrete
    IF @w IS NULL AND EXISTS (SELECT 1 FROM dbo.expertise x JOIN dbo.actif a ON a.code = x.code_actif
                              WHERE (a.entite_detentrice = @entite
                                     OR a.entite_detentrice IN (SELECT f.entite_fille FROM dbo.fn_filiales_a_l_arrete(@entite, @arrete) f))
                                AND x.date_valeur = TRY_CAST(@arrete AS DATE))
        SET @w = N'expertise';
    IF @w IS NULL
        SET @travail = 0;
    ELSE
        SET @trouve = dbo.fn_libelle_travail(@w);
END;

GO

