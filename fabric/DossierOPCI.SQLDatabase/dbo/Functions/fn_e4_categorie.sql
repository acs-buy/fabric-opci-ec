
-- ------------------------------------------------------------------ outils
-- La categorie d'obligation (code de obligation_distribution) d'une saisie : code de la table, code du referentiel
-- (RESULTAT, PLUS_VALUES, EXONEREES) ou libelle du referentiel ; NULL si rien ne correspond.
CREATE   FUNCTION dbo.fn_e4_categorie (@x NVARCHAR (300))
RETURNS VARCHAR (20)
AS
BEGIN
    SET @x = LTRIM(RTRIM(@x));
    DECLARE @ref VARCHAR (30) = (SELECT TOP (1) categorie FROM dbo.ref_obligation_distribution WHERE categorie = @x OR libelle = @x);
    RETURN CASE WHEN @x IN ('REVENUS_85', 'PLUS_VALUES_50', 'DIVIDENDES_SIIC_100') THEN @x
                WHEN @ref = 'RESULTAT' THEN 'REVENUS_85'
                WHEN @ref = 'PLUS_VALUES' THEN 'PLUS_VALUES_50'
                WHEN @ref = 'EXONEREES' THEN 'DIVIDENDES_SIIC_100' END;
END;

GO

