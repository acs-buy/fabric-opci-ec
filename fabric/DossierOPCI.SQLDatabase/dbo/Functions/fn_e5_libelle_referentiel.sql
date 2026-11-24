-- ------------------------------------------------------------------ le nom d'un referentiel au registre, sinon sa table
-- ecran 5
CREATE   FUNCTION dbo.fn_e5_libelle_referentiel (@table VARCHAR (120))
RETURNS NVARCHAR (160)
AS
BEGIN
    RETURN ISNULL((SELECT TOP (1) r.libelle FROM dbo.ref_referentiel r WHERE r.table_nom = @table), CAST(@table AS NVARCHAR (160)));
END;

GO

