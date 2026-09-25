CREATE   FUNCTION dbo.fn_dossier_verrouille (@entite VARCHAR (20), @arrete VARCHAR (20))
RETURNS BIT
AS
BEGIN
    RETURN CASE WHEN EXISTS (SELECT 1 FROM dbo.dossier_verrou WHERE entite = @entite AND arrete = @arrete AND verrouille = 1)
                THEN 1 ELSE 0 END;
END;

GO

