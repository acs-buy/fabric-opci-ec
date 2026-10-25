-- ------------------------------------------------------------------ la forme du code d'un referentiel : les libelles des colonnes de sa cle, joints par « · »
-- ecran 5, lot 1, script 323 (61_DEPLOIEMENT/generer_e5_323_procedures_de_tenue.py)
CREATE   FUNCTION dbo.fn_e5_forme_cle (@table VARCHAR (120))
RETURNS NVARCHAR (400)
AS
BEGIN
    DECLARE @f NVARCHAR (400), @sep NVARCHAR (3) = N' ' + NCHAR (183) + N' ';
    SELECT @f = STRING_AGG(CAST(dbo.fn_e5_libelle_colonne(@table, c.name) AS NVARCHAR (MAX)), @sep)
                WITHIN GROUP (ORDER BY ic.key_ordinal)
    FROM sys.indexes i
    JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
    JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
    WHERE i.object_id = OBJECT_ID(N'dbo.' + QUOTENAME(@table)) AND i.is_primary_key = 1;
    RETURN @f;
END;

GO

