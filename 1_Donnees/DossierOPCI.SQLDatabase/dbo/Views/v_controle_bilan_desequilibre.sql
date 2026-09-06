
-- --- 7 : le bilan et le sens, sur les arretes qui portent une balance ---
CREATE   VIEW dbo.v_controle_bilan_desequilibre AS
SELECT a.entite, a.arrete,
       SUM(CASE WHEN a.etat = 'BILAN_ACTIF' AND a.type_ligne = 'DETAIL'
                THEN a.exercice_n ELSE 0 END)  AS total_actif,
       SUM(CASE WHEN a.etat = 'BILAN_PASSIF' AND a.type_ligne = 'DETAIL'
                THEN a.exercice_n ELSE 0 END)  AS total_passif,
       SUM(CASE WHEN a.etat = 'BILAN_ACTIF' AND a.type_ligne = 'DETAIL'
                THEN a.exercice_n
                WHEN a.etat = 'BILAN_PASSIF' AND a.type_ligne = 'DETAIL'
                THEN -a.exercice_n ELSE 0 END) AS ecart
FROM dbo.v_ligne_etat_montant a
JOIN dbo.ref_arrete r ON r.entite = a.entite AND r.arrete = a.arrete
WHERE a.etat IN ('BILAN_ACTIF', 'BILAN_PASSIF')
  AND r.porte_balance = 1
GROUP BY a.entite, a.arrete
HAVING ABS(SUM(CASE WHEN a.etat = 'BILAN_ACTIF' AND a.type_ligne = 'DETAIL'
                    THEN a.exercice_n
                    WHEN a.etat = 'BILAN_PASSIF' AND a.type_ligne = 'DETAIL'
                    THEN -a.exercice_n ELSE 0 END)) > 0.005;

GO

