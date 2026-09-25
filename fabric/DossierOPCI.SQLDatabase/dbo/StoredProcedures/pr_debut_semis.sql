-- =====================================================================
-- LE CONTEXTE DE SEMIS, ET LA PROTECTION D'UN REFERENTIEL.
--
-- POURQUOI CE SCRIPT EST SI TOT DANS LA SEQUENCE. Les semis des
-- referentiels commencent au script 17, et chacun a besoin de 2 choses
-- qui doivent donc exister avant lui : la declaration du contexte de
-- semis, et la colonne modifie_le sur la table qu'il alimente. Un script
-- unique place en fin de sequence ne pourrait pas les servir.
--
-- CE QUE LE CONTEXTE RESOUT. Un reviseur corrige une question dans la
-- grille du portail ; au rejeu de la sequence, le semis ecrasait sa
-- correction. Desormais chaque semis conditionne ses mises a jour a
-- modifie_le IS NULL. Mais si le semis lui-meme horodatait ses lignes,
-- son premier passage interdirait a tous les suivants de corriger ses
-- propres lignes : d'ou le contexte, que le declencheur d'horodatage lit
-- pour ne rien poser quand la session est un semis.
--
-- VERIFIE SUR PIECE LE 04/09/2026, 2 points de plateforme.
--  1. sp_set_session_context et SESSION_CONTEXT fonctionnent dans la
--     base SQL Fabric : eprouve, la valeur posee est relue dans la meme
--     session.
--  2. La recursion des declencheurs est desactivee sur cette base,
--     DATABASEPROPERTYEX rend 0 : un declencheur AFTER UPDATE peut donc
--     ecrire sur sa propre table sans se rappeler lui-meme.
-- A executer contre la BASE SQL Fabric DossierOPCI.
-- =====================================================================

-- --- 1 : les 2 procedures que chaque semis appelle -------------------
CREATE   PROCEDURE dbo.pr_debut_semis
AS
BEGIN
    SET NOCOUNT ON;
    -- Le contexte vaut pour la session, jusqu'a sa fermeture ou jusqu'a
    -- l'appel de pr_fin_semis. Le declencheur d'horodatage le lit.
    EXEC sp_set_session_context @key = N'semis', @value = 1;
END;

GO

