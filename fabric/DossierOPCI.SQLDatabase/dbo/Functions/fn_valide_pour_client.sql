
CREATE   FUNCTION dbo.fn_valide_pour_client (@entite VARCHAR (20), @arrete VARCHAR (20))
RETURNS BIT
AS
BEGIN
    RETURN CASE WHEN EXISTS (SELECT 1 FROM dbo.v_visa_cloture_courant
                             WHERE entite = @entite AND arrete = @arrete AND decision = 'VISE') THEN 1 ELSE 0 END;
END;

GO

