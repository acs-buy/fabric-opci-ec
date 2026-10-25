
-- ===================================================================== 1. LES OUTILS
-- ------------------------------------------------------------------ le type d'une colonne, a la forme d'un CAST
-- ecran 5, lot 1, script 323 (61_DEPLOIEMENT/generer_e5_323_procedures_de_tenue.py)
CREATE   FUNCTION dbo.fn_e5_type_colonne (@table SYSNAME, @colonne SYSNAME)
RETURNS NVARCHAR (60)
AS
BEGIN
    DECLARE @t NVARCHAR (60);
    SELECT @t = CAST(TYPE_NAME(c.user_type_id) AS NVARCHAR (60))
              + CASE WHEN TYPE_NAME(c.user_type_id) IN (N'varchar', N'char', N'varbinary', N'binary')
                     THEN N' (' + CASE WHEN c.max_length = -1 THEN N'MAX' ELSE CAST(c.max_length AS NVARCHAR (10)) END + N')'
                     WHEN TYPE_NAME(c.user_type_id) IN (N'nvarchar', N'nchar')
                     THEN N' (' + CASE WHEN c.max_length = -1 THEN N'MAX' ELSE CAST(c.max_length / 2 AS NVARCHAR (10)) END + N')'
                     WHEN TYPE_NAME(c.user_type_id) IN (N'decimal', N'numeric')
                     THEN N' (' + CAST(c.precision AS NVARCHAR (4)) + N', ' + CAST(c.scale AS NVARCHAR (4)) + N')'
                     WHEN TYPE_NAME(c.user_type_id) IN (N'datetime2', N'time', N'datetimeoffset')
                     THEN N' (' + CAST(c.scale AS NVARCHAR (4)) + N')'
                     ELSE N'' END
    FROM sys.columns c
    WHERE c.object_id = OBJECT_ID(N'dbo.' + QUOTENAME(@table)) AND c.name = @colonne;
    RETURN @t;
END;

GO

