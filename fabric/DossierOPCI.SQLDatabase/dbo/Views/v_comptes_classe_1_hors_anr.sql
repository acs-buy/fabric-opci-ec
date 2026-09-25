
-- --- depuis 63_SQL/46_anr_vl.sql : v_comptes_classe_1_hors_anr -------------------
-- --- 2 : le filet, tout compte de classe 1 mouvemente hors perimetre ---
-- ATTENDU : zero ligne. Une ligne = un prefixe de classe 1 que la
-- definition de l'ANR ne couvre pas, a trancher avant publication.
CREATE   VIEW dbo.v_comptes_classe_1_hors_anr AS
SELECT DISTINCT l.entite, l.arrete, e.compte_num
FROM dbo.v_ecriture_normalisee e
INNER JOIN dbo.lot_ecritures l ON l.id = e.lot_id
WHERE l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
  AND l.famille <> 'DERIVABLE'
  AND e.compte_num LIKE '1%'
  AND e.compte_num NOT LIKE '10%' AND e.compte_num NOT LIKE '11%'
  AND e.compte_num NOT LIKE '12%' AND e.compte_num NOT LIKE '13%'
  AND e.compte_num NOT LIKE '14%' AND e.compte_num NOT LIKE '19%';

GO

