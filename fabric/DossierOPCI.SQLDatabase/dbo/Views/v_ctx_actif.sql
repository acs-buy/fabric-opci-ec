-- 178 -- Les 4 derniers objets, rattaches au contexte par un chemin indirect
-- 13/09/2026. Fin du branchement commence aux scripts 175, 176 et 177. Ces 4 objets ne portent ni
-- entite ni arrete : chacun se rattache par une table voisine, relevee ce jour.
--   actif             -> entite_detentrice, l'entite qui detient l'actif
--   expertise         -> code_actif, puis l'entite detentrice de cet actif
--   ecriture          -> lot_id, puis l'entite et l'arrete de lot_ecritures
--   feuille_question  -> cote, puis l'entite et l'arrete de feuille_travail
-- Chaque vue garde UNE SEULE table dans son FROM, pour rester saisissable.

-- Les actifs du perimetre. Pas de filtre d'arrete : un actif existe independamment de l'arrete,
-- c'est sa valeur qui en depend.
CREATE   VIEW dbo.v_ctx_actif AS
SELECT t.* FROM dbo.actif t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p WHERE p.entite = t.entite_detentrice);

GO

