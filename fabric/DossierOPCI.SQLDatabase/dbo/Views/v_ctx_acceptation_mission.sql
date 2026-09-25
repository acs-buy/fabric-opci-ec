-- 176 -- Les grilles de travail filtrees par le contexte du reviseur
-- 13/09/2026. Suite du script 175, qui avait branche les 5 grilles de l'ecran 1.1. Celui-ci
-- traite tous les objets des 4 parcours de travail qui portent l'entite, l'arrete ou les 2.
-- La regle est la meme partout : un EXISTS sur v_mon_perimetre, jamais une jointure, pour que
-- la vue reste SAISISSABLE. Une vue qui joint 2 tables n'accepte plus l'insertion.
-- Sans contexte choisi, toutes ces vues sont vides, ce qui est voulu.
-- Les 5 objets qui ne portent ni entite ni arrete sont traites a part, cf. la fin du fichier.

CREATE   VIEW dbo.v_ctx_acceptation_mission AS
SELECT t.* FROM dbo.acceptation_mission t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p WHERE p.entite = t.entite);

GO

