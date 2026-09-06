-- C37 : une piece rattachee a une exigence dont le cycle ne correspond
-- pas a sa nature. Un releve bancaire rattache a une exigence du cycle
-- IMMO serait un rattachement de complaisance. ATTENDU zero.
CREATE   VIEW dbo.v_controle_rattachement_incoherent AS
SELECT u.rattachement_id, u.piece_id, u.nom_fichier, u.nature, u.famille,
       u.cycle, u.exigence
FROM dbo.v_usages_piece u
-- Le cycle HB admet la famille FINANCIER, corrige le 04/09/2026 apres
-- que le rejeu complet a signale 1 rattachement : le semis attribue
-- CONTRAT_EMPRUNT a l'exigence « Etat des engagements donnes et recus »
-- du cycle HB, et un engagement hors bilan est le plus souvent une
-- garantie, un cautionnement ou une convention financiere. La liste des
-- cycles admis etait trop etroite, non le rattachement.
WHERE u.cycle IS NOT NULL
  AND ((u.famille = 'IMMOBILIER' AND u.cycle NOT IN ('IMMO', 'VALO', 'PART'))
    OR (u.famille = 'FINANCIER'
        AND u.cycle NOT IN ('TRESO', 'FIN', 'CAPITAL', 'HB')));

GO

