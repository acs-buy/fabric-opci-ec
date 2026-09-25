

-- --- 3 : les controles ----------------------------------------------
-- C66 : le total des frais du tableau 335-10 doit egaler la ligne VI du
-- compte de resultat, les 2 portant les frais de gestion et de
-- fonctionnement externes. ATTENDU zero ecart.
CREATE   VIEW dbo.v_controle_annexe_335_10 AS
SELECT m.entite, m.arrete,
       SUM(CASE WHEN m.type_ligne = 'CALCUL' THEN m.exercice_n ELSE 0 END)
                                                   AS total_335_10,
       cr.exercice_n                               AS ligne_vi_du_resultat,
       SUM(CASE WHEN m.type_ligne = 'CALCUL' THEN m.exercice_n ELSE 0 END)
         - COALESCE(cr.exercice_n, 0)              AS ecart
FROM dbo.v_ligne_annexe_montant m
LEFT JOIN dbo.v_compte_resultat cr ON cr.entite = m.entite
                                  AND cr.arrete = m.arrete
                                  AND cr.code = 'R_TVI'
WHERE m.article = '335-10'
GROUP BY m.entite, m.arrete, cr.exercice_n;

GO

