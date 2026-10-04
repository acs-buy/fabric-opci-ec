
-- 5. LES CONTROLES C61 ET C69 LISENT LES LIGNES TOTALES. Ecrits pour l'annexe de 114 et 116, ils additionnaient les
-- lignes une a une : C61 comptait les sommes distribuables avec leurs composantes, C69 ignorait une composante NULL et
-- rendait distribuable le resultat de 2022 dont la repartition des acomptes est a remplir. Un total NULL rend l'ecart
-- NULL : le rapprochement n'est pas calculable, et le registre ne le compte pas en anomalie (124).
CREATE   VIEW dbo.v_controle_annexe_333_1 AS
SELECT m.entite, m.arrete,
       MAX(CASE WHEN m.code = 'CAPITAL' THEN m.colonne_1 END)  AS capital,
       MAX(CASE WHEN m.code = 'SD_TOTAL' THEN m.colonne_1 END) AS sommes_distribuables,
       MAX(CASE WHEN m.code = 'CP_TOTAL' THEN m.colonne_1 END) AS total_capitaux_propres,
       a.actif_net_reevalue                                    AS actif_net_du_script_46,
       MAX(CASE WHEN m.code = 'CP_TOTAL' THEN m.colonne_1 END) - a.actif_net_reevalue AS ecart
FROM dbo.v_ligne_annexe_montant m
LEFT JOIN dbo.v_anr_entite a ON a.entite = m.entite AND a.arrete = m.arrete
WHERE m.article = '333-1'
GROUP BY m.entite, m.arrete, a.actif_net_reevalue;

GO

