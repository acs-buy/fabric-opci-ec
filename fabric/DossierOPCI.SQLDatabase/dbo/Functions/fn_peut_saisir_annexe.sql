
CREATE   FUNCTION dbo.fn_peut_saisir_annexe (@entite VARCHAR (20), @qui NVARCHAR (400), @le DATE)
RETURNS BIT
AS
BEGIN
    RETURN dbo.fn_tient_role_mission(@entite, @qui, @le);
END;

GO

