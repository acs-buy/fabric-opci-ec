
-- --- 4 : E4-2c, le cadrage des prets --------------------------------
-- Un seul poste « pret intragroupe », sans decomposition par nature de
-- pret : decision du candidat du 04/09/2026. L'encours vu de la filiale
-- contre la creance vue de l'OPCI, et les interets des 2 cotes.
CREATE   VIEW dbo.v_cadrage_pret_intragroupe AS
SELECT f.arrete,
       f.entite_debitrice                  AS filiale,
       f.entite_creditrice                 AS opci,
       SUM(CASE WHEN f.nature = 'PRET' THEN f.montant ELSE 0 END)
                                           AS encours_vu_de_la_filiale,
       SUM(CASE WHEN f.nature = 'PRET' THEN f.montant ELSE 0 END)
                                           AS creance_vue_de_l_opci,
       SUM(CASE WHEN f.nature = 'INTERET' THEN f.montant ELSE 0 END)
                                           AS interets_de_la_periode,
       -- La reciprocite : le meme flux est porte une fois, donc les 2
       -- colonnes sont egales PAR CONSTRUCTION. La vue de controle
       -- confronte la table aux ECRITURES des 2 entites, qui est le
       -- seul rapprochement qui prouve quelque chose.
       CAST(1 AS BIT)                      AS reciproque_par_construction
FROM dbo.flux_intragroupe f
GROUP BY f.arrete, f.entite_debitrice, f.entite_creditrice;

GO

