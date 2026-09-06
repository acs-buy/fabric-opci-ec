
-- --- 3 : le plafond, I de l'article L. 214-69, lu de la balance ---------
-- 1 : resultat distribuable des produits = soldes crediteurs de 120, 111,
--     191 et 192, le 129 (acomptes verses, debiteur) se deduisant de
--     lui-meme. 2 : plus-values = 76 de l'exercice + 112, corrige de 193.
-- v_balance rend debit moins credit : un solde crediteur y est negatif,
-- le plafond se lit donc en credit moins debit, soit l'oppose.
CREATE   VIEW dbo.v_plafond_distribuable AS
WITH soldes AS (
    SELECT b.entite, b.arrete,
           SUM(CASE WHEN b.compte LIKE '120%' OR b.compte LIKE '129%'
                      OR b.compte LIKE '111%'
                      OR b.compte LIKE '191%' OR b.compte LIKE '192%'
                    THEN -b.balance_finale ELSE 0 END) AS resultat_distribuable,
           SUM(CASE WHEN b.compte LIKE '76%' OR b.compte LIKE '112%'
                      OR b.compte LIKE '193%'
                    THEN -b.balance_finale ELSE 0 END) AS plus_values_distribuables
    FROM dbo.v_balance b
    GROUP BY b.entite, b.arrete
)
SELECT entite, arrete,
       CAST(resultat_distribuable AS DECIMAL (19,2))      AS resultat_distribuable,
       CAST(plus_values_distribuables AS DECIMAL (19,2))  AS plus_values_distribuables,
       CAST(resultat_distribuable
          + plus_values_distribuables AS DECIMAL (19,2))  AS plafond_distribuable
FROM soldes;

GO

