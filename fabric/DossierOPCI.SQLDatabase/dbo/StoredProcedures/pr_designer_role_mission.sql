-- 219. Designer une personne sur un role d'un dossier, et fermer le mandat precedent.
--
-- BESOIN : aucun ecran ne permet aujourd'hui de designer l'associe signataire d'un dossier. role_mission
-- se tient a la main, en base. C'est le manque que le parcours du 21/09/2026 a rendu visible : le createur
-- d'un dossier en devient chef de mission (script 218), mais l'associe qui visera, lui, ne se designe nulle
-- part. Cette procedure est la brique metier de l'ecran Referentiels R1, encore a construire.
--
-- CE QU'ELLE N'EST PAS : une porte derobee de recette. Elle est appelee par la recette comme elle le sera
-- par l'ecran, avec la meme trace et les memes refus. La recette ne contourne rien, elle emprunte le chemin.
--
-- REGLES, portees par la base et non par cette procedure :
--   fk_role_role       : le role existe au referentiel (ASSOCIE, CHEF_MISSION, PREPARATEUR) ;
--   fk_role_entite     : l'entite existe ; un role est donc TOUJOURS par dossier, jamais « tous clients » ;
--   tr_role_sans_chevauchement : 2 personnes ne tiennent pas le meme role sur la meme entite au meme moment.
--     Le mandat en cours se ferme donc AVANT d'en ouvrir un autre, ce que fait cette procedure.
-- L'intervalle etant ferme a gauche et ouvert a droite, le mandat ferme ce jour et celui ouvert ce jour
-- ne se chevauchent pas.
--
-- Prerequis : role_mission, ref_role. Rejouable : redesigner la meme personne ne fait rien.

CREATE   PROCEDURE dbo.pr_designer_role_mission
    @entite     VARCHAR (20),
    @role       VARCHAR (20),
    @personne   NVARCHAR (400),
    @connexion  NVARCHAR (400) = NULL,   -- l'UPN, sans lequel la personne ne sera pas reconnue a l'ecran
    @par        NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @entite)
        THROW 50291, N'L''entité désignée n''existe pas.', 1;
    IF @personne IS NULL OR LTRIM(RTRIM(@personne)) = N''
        THROW 50292, N'Le nom de la personne est obligatoire.', 1;
    SET @connexion = NULLIF(LTRIM(RTRIM(@connexion)), N'');

    DECLARE @aujourdhui DATE = CAST(SYSUTCDATETIME() AS DATE);
    DECLARE @en_cours NVARCHAR (400) = (SELECT TOP (1) personne FROM dbo.role_mission
                                         WHERE entite = @entite AND role = @role AND au IS NULL
                                         ORDER BY du DESC);
    IF @en_cours = @personne
    BEGIN
        SELECT @entite AS entite, @role AS role,
               @personne + N' tient déjà le rôle ' + @role + N' sur ' + @entite + N'.' AS message;
        RETURN;
    END;

    BEGIN TRY
    BEGIN TRANSACTION;
    -- le mandat en cours se ferme le jour meme : sans cela, le declencheur refuse le suivant
    UPDATE dbo.role_mission SET au = @aujourdhui
     WHERE entite = @entite AND role = @role AND au IS NULL AND du < @aujourdhui;
    -- un mandat ouvert le jour meme ne peut pas se fermer le jour meme (ck_role_intervalle) : il se retire
    DELETE dbo.role_mission
     WHERE entite = @entite AND role = @role AND au IS NULL AND du >= @aujourdhui;

    INSERT INTO dbo.role_mission (entite, role, personne, du, au, pose_par, pose_le, connexion)
    VALUES (@entite, @role, @personne, @aujourdhui, NULL, @par, SYSUTCDATETIME(), @connexion);
    COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @entite AS entite, @role AS role,
           @personne + N' désigné' + CASE WHEN @role = 'ASSOCIE' THEN N' associé signataire'
                                          WHEN @role = 'CHEF_MISSION' THEN N' chef de mission'
                                          ELSE N' ' + @role END
         + N' de ' + @entite + N'.' + CASE WHEN @en_cours IS NULL THEN N''
                                           ELSE N' Le mandat de ' + @en_cours + N' est clos.' END AS message;
END;

GO

