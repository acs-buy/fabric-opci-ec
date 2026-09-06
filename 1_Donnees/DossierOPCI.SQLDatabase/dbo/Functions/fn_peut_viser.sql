
-- --- 5 : la fonction que les procedures de visa liront ---------------
-- Elle rend 1 si la personne tenait un role visant sur l'entite a la date
-- donnee. Les procedures du lot F l'appelleront avant tout visa, et la
-- date passee sera celle de l'arrete et non celle du jour : un visa se
-- juge a la date ou il porte.
CREATE   FUNCTION dbo.fn_peut_viser (
    @entite   VARCHAR (20),
    @personne NVARCHAR (200),
    @date     DATE
)
RETURNS BIT
AS
BEGIN
    DECLARE @oui BIT = 0;
    IF EXISTS (SELECT 1 FROM dbo.role_mission r
               JOIN dbo.ref_role f ON f.code = r.role
               WHERE r.entite = @entite AND r.personne = @personne
                 AND f.vise = 1
                 AND r.du <= @date
                 AND (r.au IS NULL OR r.au > @date))
        SET @oui = 1;
    RETURN @oui;
END

GO

