

-- --- 3 : les controles ----------------------------------------------
-- C63 : le total des capitaux propres du tableau 333-1 doit egaler
-- l'actif net que le script 46 calcule. ATTENDU zero ecart.
CREATE   VIEW dbo.v_controle_annexe_333_1 AS
SELECT m.entite, m.arrete,
       SUM(CASE WHEN m.code = 'CAPITAL' THEN m.exercice_n ELSE 0 END)
                                                     AS capital,
       SUM(CASE WHEN m.type_ligne = 'CALCUL' AND m.code <> 'CAPITAL'
                THEN m.exercice_n ELSE 0 END)        AS sommes_distribuables,
       SUM(CASE WHEN m.type_ligne = 'CALCUL' THEN m.exercice_n ELSE 0 END)
                                                     AS total_capitaux_propres,
       a.actif_net_reevalue                          AS actif_net_du_script_46,
       SUM(CASE WHEN m.type_ligne = 'CALCUL' THEN m.exercice_n ELSE 0 END)
         - a.actif_net_reevalue                      AS ecart
FROM dbo.v_ligne_annexe_montant m
LEFT JOIN dbo.v_anr_entite a ON a.entite = m.entite AND a.arrete = m.arrete
WHERE m.article = '333-1'
GROUP BY m.entite, m.arrete, a.actif_net_reevalue;

GO

