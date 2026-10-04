
-- UN ACOMPTE NON REPARTI : le compte 129 ou 198 porte un solde hors de ses sous-comptes 1291, 1293, 1981, 1982.
CREATE   VIEW dbo.v_acompte_non_reparti AS
SELECT lo.entite, lo.arrete
FROM dbo.v_ecriture_normalisee e JOIN dbo.lot_ecritures lo ON lo.id = e.lot_id
WHERE lo.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
  AND ((e.compte_num LIKE '129%' AND e.compte_num NOT LIKE '1291%' AND e.compte_num NOT LIKE '1293%')
    OR (e.compte_num LIKE '198%' AND e.compte_num NOT LIKE '1981%' AND e.compte_num NOT LIKE '1982%'))
GROUP BY lo.entite, lo.arrete
HAVING ABS(SUM(e.debit - e.credit)) > 0.005;

GO

