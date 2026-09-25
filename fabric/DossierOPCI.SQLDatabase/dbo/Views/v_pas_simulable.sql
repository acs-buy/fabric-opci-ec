
-- --- 2 : le pas du curseur, calcule et non plus fixe -------------------
-- Un pas fixe de 100,00 ne tient qu'a une echelle. Le pas se derive
-- desormais de l'intervalle, pour rendre entre 100 et 1 000 valeurs quelle
-- que soit la taille du dossier : c'est la servitude des 1 000 valeurs
-- uniques d'un segment qui fixe le plafond, et la lisibilite du curseur
-- qui fixe le plancher.
--
-- La formule prend la puissance de 10 immediatement inferieure a
-- l'intervalle divise par 200. Elle rend 100,00 pour un intervalle de
-- 26 400,00, soit exactement le pas de l'ancien jeu, et 10 000,00 pour un
-- intervalle de 5 358 431,50, soit 536 valeurs.
CREATE   VIEW dbo.v_pas_simulable AS
SELECT s.cle_arrete, s.entite, s.arrete, s.exercice,
       s.obligation_minimale, s.plafond_distribuable,
       CAST(s.plafond_distribuable - s.obligation_minimale AS DECIMAL (19,2))
           AS intervalle,
       CAST(CASE
           WHEN s.plafond_distribuable - s.obligation_minimale <= 0 THEN 1.00
           WHEN (s.plafond_distribuable - s.obligation_minimale) / 200.0 < 1
                THEN 1.00
           ELSE POWER(10.0, FLOOR(LOG10(
                (s.plafond_distribuable - s.obligation_minimale) / 200.0)))
       END AS DECIMAL (19,2)) AS pas
FROM dbo.v_simulation_distribution s;

GO

