
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
               -- 07/09/2026 : la personne se reconnait par son nom ou par sa connexion,
               -- les boutons de l'ecran passant l'adresse de l'utilisateur courant.
               WHERE r.entite = @entite
                 AND (r.personne = @personne OR r.connexion = @personne)
                 AND f.vise = 1
                 AND r.du <= @date
                 AND (r.au IS NULL OR r.au > @date))
        SET @oui = 1;
    RETURN @oui;
END

GO

