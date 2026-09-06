-- La fonction qui remplace dbo.fn_peut_viser dans le verrou : elle prend
-- la nature. L'ancienne reste, d'autres objets la lisant.
CREATE   FUNCTION dbo.fn_peut_viser_nature (
    @entite   VARCHAR (20),
    @personne NVARCHAR (200),
    @nature   VARCHAR (12),
    @date     DATE
)
RETURNS BIT
AS
BEGIN
    DECLARE @oui BIT = 0;
    IF EXISTS (SELECT 1 FROM dbo.role_mission r
               JOIN dbo.ref_role f ON f.code = r.role
               JOIN dbo.role_nature_visa n ON n.role_code = r.role
                                          AND n.nature = @nature
               WHERE r.entite = @entite AND r.personne = @personne
                 AND f.vise = 1
                 AND r.du <= @date
                 AND (r.au IS NULL OR r.au > @date))
        SET @oui = 1;
    RETURN @oui;
END

GO

