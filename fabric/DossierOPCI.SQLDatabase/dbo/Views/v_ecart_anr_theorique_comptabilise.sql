
-- --- depuis 63_SQL/127_valeur_historique_des_filiales.sql : v_ecart_anr_theorique_comptabilise ---
-- --- 2 : la vue de l'ecart, qui connait desormais la regle ----------
-- UNE FILIALE TENUE EN VALEUR HISTORIQUE N'EST PAS EN ECART. La
-- redaction du script 107 attendait un lot de valorisation de chaque
-- entite. Elle comptait donc 12 anomalies qui decrivaient la regle du
-- dossier, et le tableau de bord en heritait.
CREATE   VIEW dbo.v_ecart_anr_theorique_comptabilise AS
SELECT f.entite, f.arrete,
       f.capitaux_propres_comptables,
       f.differences_d_estimation          AS difference_theorique,
       COALESCE(c.immeubles, 0)            AS difference_comptabilisee,
       -- UNE FILIALE NE PORTE AUCUN ECART : le sien est nul par regle, et
       -- la colonne le dit au lieu d'afficher un manque.
       CASE WHEN d.entite_fille IS NOT NULL THEN CAST(0 AS DECIMAL (19,2))
            ELSE f.differences_d_estimation - COALESCE(c.immeubles, 0)
            END                            AS ecart,
       COALESCE(c.titres_et_comptes_courants, 0)
                                           AS hors_comparaison_275_276,
       f.actif_net_reevalue                AS anr_theorique,
       e.actif_net_reevalue                AS anr_comptabilise,
       CAST(CASE WHEN d.entite_fille IS NOT NULL THEN 1 ELSE 0 END AS BIT)
                                           AS tenue_en_valeur_historique,
       CASE WHEN d.entite_fille IS NOT NULL
            THEN N'filiale tenue en valeur historique : la différence d''estimation de ses immeubles est portée par la mère au compte 275, règle arrêtée le 05/09/2026'
            WHEN ABS(f.differences_d_estimation
                     - COALESCE(c.immeubles, 0)) < 0.005
            THEN N'les 2 chemins concordent sur les immeubles'
            WHEN NOT EXISTS (SELECT 1 FROM dbo.lot_ecritures z
                             WHERE z.entite = f.entite AND z.arrete = f.arrete
                               AND z.famille = 'DERIVABLE')
            THEN N'aucun lot de valorisation n''a ete genere pour cet arrete : la difference d''estimation reste entiere a comptabiliser'
            WHEN f.differences_d_estimation > COALESCE(c.immeubles, 0)
            THEN N'une part de la difference d''estimation des immeubles reste a comptabiliser'
            ELSE N'la difference comptabilisee sur les immeubles excede celle que les valeurs actuelles justifient'
            END                            AS lecture
FROM dbo.v_anr_filiale f
JOIN dbo.v_anr_entite e ON e.entite = f.entite AND e.arrete = f.arrete
LEFT JOIN (SELECT DISTINCT entite_fille FROM dbo.detention) d
       ON d.entite_fille = f.entite
OUTER APPLY (
    SELECT SUM(CASE WHEN e2.compte_num LIKE '271%'
                      OR e2.compte_num LIKE '272%'
                      OR e2.compte_num LIKE '273%'
                      OR e2.compte_num LIKE '274%'
                    THEN e2.debit - e2.credit ELSE 0 END) AS immeubles,
           SUM(CASE WHEN e2.compte_num LIKE '275%'
                      OR e2.compte_num LIKE '276%'
                    THEN e2.debit - e2.credit ELSE 0 END)
               AS titres_et_comptes_courants
    FROM dbo.v_ecriture_normalisee e2
    JOIN dbo.lot_ecritures l2 ON l2.id = e2.lot_id
    WHERE l2.entite = f.entite AND l2.arrete = f.arrete
      AND l2.famille = 'DERIVABLE'
      AND l2.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
      AND e2.compte_num LIKE '27%'
) AS c;

GO

