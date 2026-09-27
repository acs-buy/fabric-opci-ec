-- LA RECETTE NE PORTE PLUS D'ADRESSE EN DUR.
-- La valeur par defaut portait l'adresse d'un compte du cabinet. Cette procedure part dans le
-- depot public a chaque extraction des definitions : l'adresse en serait partie avec elle.
-- L'appelant fournit desormais la connexion, et un oubli se voit au lieu de passer inapercu.
-- Corrige le 26/09/2026.
CREATE PROCEDURE dbo.pr_recette_associe_du_dossier
    @entite     VARCHAR (20),
    @connexion  NVARCHAR (400) = NULL,
    @par        NVARCHAR (400) = N'recette'
AS
BEGIN
    SET NOCOUNT ON;
    IF @connexion IS NULL OR LTRIM(RTRIM(@connexion)) = N''
        THROW 50219, N'La connexion de l''associé est obligatoire : cette procédure ne suppose aucun compte.', 1;
    EXEC dbo.pr_designer_role_mission @entite = @entite, @role = 'ASSOCIE',
         @personne = N'Associé signataire du cabinet', @connexion = @connexion, @par = @par;
END;

GO

