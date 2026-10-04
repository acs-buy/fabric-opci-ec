
-- 5. C60 : le bilan equilibre, pour les vehicules sur leurs etats, pour les filiales sur leur balance (elles tiennent
-- le plan comptable general et n'ont pas d'etats OPCI). ATTENDU zero.
CREATE   VIEW dbo.v_controle_bilan_desequilibre AS
SELECT a.entite, a.arrete,
       MAX(CASE WHEN a.code = 'A_TOTAL' THEN a.exercice_n END) AS total_actif,
       MAX(CASE WHEN a.code = 'P_TOTAL' THEN a.exercice_n END) AS total_passif,
       MAX(CASE WHEN a.code = 'A_TOTAL' THEN a.exercice_n END) - MAX(CASE WHEN a.code = 'P_TOTAL' THEN a.exercice_n END) AS ecart
FROM dbo.v_ligne_etat_montant a
JOIN dbo.ref_arrete r ON r.entite = a.entite AND r.arrete = a.arrete
WHERE a.code IN ('A_TOTAL', 'P_TOTAL') AND r.porte_balance = 1
GROUP BY a.entite, a.arrete
HAVING ABS(MAX(CASE WHEN a.code = 'A_TOTAL' THEN a.exercice_n END) - MAX(CASE WHEN a.code = 'P_TOTAL' THEN a.exercice_n END)) > 0.005
UNION ALL
SELECT lo.entite, lo.arrete, SUM(e.debit), SUM(e.credit), SUM(e.debit - e.credit)
FROM dbo.lot_ecritures lo
JOIN dbo.ecriture e ON e.lot_id = lo.id
JOIN dbo.ref_arrete r ON r.entite = lo.entite AND r.arrete = lo.arrete AND r.porte_balance = 1
JOIN dbo.ref_entite x ON x.code = lo.entite AND x.forme_vehicule IS NULL
WHERE lo.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
GROUP BY lo.entite, lo.arrete
HAVING ABS(SUM(e.debit - e.credit)) > 0.005;

GO

