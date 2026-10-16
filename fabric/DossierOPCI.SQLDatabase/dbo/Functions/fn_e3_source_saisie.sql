
-- ------------------------------------------------------------------ n° 2 : la valeur retenue
CREATE   FUNCTION dbo.fn_e3_source_saisie (@source NVARCHAR (60))
RETURNS VARCHAR (20)
AS
BEGIN
    RETURN (SELECT TOP (1) source FROM dbo.ref_source_valeur
            WHERE saisissable = 1 AND (libelle = LTRIM(RTRIM(@source)) OR source = LTRIM(RTRIM(@source))));
END;

GO

