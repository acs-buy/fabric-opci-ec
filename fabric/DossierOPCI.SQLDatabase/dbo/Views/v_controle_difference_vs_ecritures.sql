
CREATE VIEW dbo.v_controle_difference_vs_ecritures AS
WITH actifs AS (
    /* La difference d'estimation telle que les actifs et leurs valeurs la portent. */
    SELECT entite, arrete,
           SUM(CASE WHEN famille = 'IMMEUBLE'       THEN difference_estimation ELSE 0 END) AS diff_immeubles,
           SUM(CASE WHEN famille = 'TITRE'          THEN difference_estimation ELSE 0 END) AS diff_titres,
           SUM(CASE WHEN famille = 'COMPTE_COURANT' THEN difference_estimation ELSE 0 END) AS diff_comptes_courants,
           SUM(difference_estimation) AS diff_actifs
    FROM dbo.v_ecran_differences_synthese s
    WHERE EXISTS (SELECT 1 FROM dbo.ref_entite r
                  WHERE r.code = s.entite AND r.forme_vehicule IS NOT NULL)
    GROUP BY entite, arrete
),
ecrits AS (
    /* La difference d'estimation telle que les ecritures de reevaluation la portent.
       Meme perimetre de lots que dbo.v_anr_entite : famille DERIVABLE, statuts servis. */
    SELECT l.entite, l.arrete,
           SUM(CASE WHEN e.compte_num LIKE '271%' THEN e.debit - e.credit ELSE 0 END) AS ecr_immeubles,
           SUM(CASE WHEN e.compte_num LIKE '275%' THEN e.debit - e.credit ELSE 0 END) AS ecr_titres,
           SUM(CASE WHEN e.compte_num LIKE '27%'  THEN e.debit - e.credit ELSE 0 END) AS ecr_total
    FROM dbo.ecriture e
    INNER JOIN dbo.lot_ecritures l ON l.id = e.lot_id
    WHERE l.famille = 'DERIVABLE'
      AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
      AND e.compte_num LIKE '27%'
      AND EXISTS (SELECT 1 FROM dbo.ref_entite r
                  WHERE r.code = l.entite AND r.forme_vehicule IS NOT NULL)
    GROUP BY l.entite, l.arrete
),
couple AS (
    SELECT entite, arrete FROM actifs
    UNION SELECT entite, arrete FROM ecrits
)
SELECT
    CONCAT(c.entite, '|', c.arrete) AS cle_ecran,
    c.entite,
    c.arrete,
    CAST(ISNULL(a.diff_actifs, 0) AS decimal(19, 2))  AS difference_des_actifs,
    CAST(ISNULL(x.ecr_total, 0)   AS decimal(19, 2))  AS difference_des_ecritures,
    CAST(ISNULL(a.diff_actifs, 0) - ISNULL(x.ecr_total, 0) AS decimal(19, 2)) AS ecart,
    CAST(ISNULL(a.diff_immeubles, 0) - ISNULL(x.ecr_immeubles, 0) AS decimal(19, 2)) AS ecart_immeubles,
    CAST(ISNULL(a.diff_titres, 0)    - ISNULL(x.ecr_titres, 0)    AS decimal(19, 2)) AS ecart_titres,
    CAST(ISNULL(a.diff_comptes_courants, 0) AS decimal(19, 2)) AS difference_comptes_courants,
    CAST(CASE WHEN ABS(ISNULL(a.diff_actifs, 0) - ISNULL(x.ecr_total, 0)) > 1.00
              THEN 1 ELSE 0 END AS bit) AS en_anomalie,
    'Reglement ANC 2021-09, articles 211-6, 212-4 et 213-4' AS fondement,
    CASE
        WHEN ABS(ISNULL(a.diff_actifs, 0) - ISNULL(x.ecr_total, 0)) <= 1.00
            THEN 'Les ecritures de reevaluation concordent avec la difference d''estimation des actifs.'
        ELSE CONCAT('ECART DE ',
                    FORMAT(ISNULL(a.diff_actifs, 0) - ISNULL(x.ecr_total, 0), 'N2', 'fr-FR'),
                    ' entre la difference des actifs et celle des ecritures',
                    CASE WHEN ABS(ISNULL(a.diff_immeubles, 0) - ISNULL(x.ecr_immeubles, 0)) > 1.00
                         THEN CONCAT(' ; immeubles : ',
                                     FORMAT(ISNULL(a.diff_immeubles, 0) - ISNULL(x.ecr_immeubles, 0), 'N2', 'fr-FR'))
                         ELSE '' END,
                    CASE WHEN ABS(ISNULL(a.diff_titres, 0) - ISNULL(x.ecr_titres, 0)) > 1.00
                         THEN CONCAT(' ; titres : ',
                                     FORMAT(ISNULL(a.diff_titres, 0) - ISNULL(x.ecr_titres, 0), 'N2', 'fr-FR'))
                         ELSE '' END,
                    '. L''actif net reevalue est calcule sur les ecritures : il est donc decale du ',
                    'meme montant, et la valeur liquidative avec lui. Regenerer le lot de ',
                    'reevaluation, ou etablir par ecrit pourquoi l''ecriture s''ecarte de ses actifs.')
    END AS message_ecran
FROM couple c
LEFT JOIN actifs a ON a.entite = c.entite AND a.arrete = c.arrete
LEFT JOIN ecrits x ON x.entite = c.entite AND x.arrete = c.arrete;

GO

