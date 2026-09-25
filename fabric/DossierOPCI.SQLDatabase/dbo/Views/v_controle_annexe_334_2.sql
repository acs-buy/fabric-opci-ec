

-- --- 3 : le controle ------------------------------------------------
-- C65 : le total du tableau 334-2 doit egaler la ligne des immeubles du
-- bilan actif, les 2 portant les memes comptes. ATTENDU zero ecart.
CREATE   VIEW dbo.v_controle_annexe_334_2 AS
SELECT m.entite, m.arrete,
       SUM(CASE WHEN m.type_ligne = 'CALCUL' THEN m.exercice_n ELSE 0 END)
                                                   AS total_334_2,
       b.exercice_n                                AS ligne_bilan_immeubles,
       SUM(CASE WHEN m.type_ligne = 'CALCUL' THEN m.exercice_n ELSE 0 END)
         - b.exercice_n                            AS ecart
FROM dbo.v_ligne_annexe_montant m
LEFT JOIN dbo.v_bilan_actif b ON b.entite = m.entite AND b.arrete = m.arrete
                             AND b.code = 'A_IMMO_1'
WHERE m.article = '334-2'
GROUP BY m.entite, m.arrete, b.exercice_n;

GO

