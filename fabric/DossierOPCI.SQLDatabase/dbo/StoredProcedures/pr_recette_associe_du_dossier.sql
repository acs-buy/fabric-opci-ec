
-- La recette designe son associe par la meme procedure : elle n'emprunte aucun chemin particulier.
CREATE   PROCEDURE dbo.pr_recette_associe_du_dossier
    @entite     VARCHAR (20),
    @connexion  NVARCHAR (400) = N'a-completer@votre-cabinet.invalid',
    @par        NVARCHAR (400) = N'recette'
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.pr_designer_role_mission @entite = @entite, @role = 'ASSOCIE',
         @personne = N'Associé signataire du cabinet', @connexion = @connexion, @par = @par;
END;

GO

