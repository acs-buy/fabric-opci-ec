
-- Gardee pour la preuve du modele semantique, en lecture (contrat, 3.1, revision 6) : la garde, sinon l'obstacle de
-- l'annexe sur la derniere version. Aucune procedure ne l'appelle.
CREATE   FUNCTION dbo.fn_obstacle_production (@entite VARCHAR (20), @arrete VARCHAR (20), @livrable VARCHAR (20), @par NVARCHAR (400))
RETURNS NVARCHAR (2000)
AS
BEGIN
    RETURN ISNULL(dbo.fn_garde_production(@entite, @arrete, @livrable, @par), dbo.fn_obstacle_annexe(@entite, @arrete, @livrable));
END;

GO

