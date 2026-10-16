
-- Un montant a l'ecran : 2 decimales, separateurs francais.
CREATE   FUNCTION dbo.fn_e3_montant (@x DECIMAL (19,4))
RETURNS NVARCHAR (40)
AS
BEGIN
    RETURN FORMAT(@x, 'N2', 'fr-FR');
END;

GO

