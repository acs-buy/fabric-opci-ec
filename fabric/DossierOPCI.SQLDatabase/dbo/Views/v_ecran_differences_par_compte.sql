
-- ------------------------------------------------------------------ n° 16 : les differences par compte du vehicule
-- Par compte de difference d'estimation du vehicule (fn_compte_difference_estimation, derive du poste du bilan) : la
-- difference des actifs, le solde du compte a la balance, le reste a passer. Les comptes 271, 275, 276 et 37 figurent
-- toujours, « aucun actif » quand la famille n'en porte pas.
CREATE   VIEW dbo.v_ecran_differences_par_compte AS
WITH veh AS (
    SELECT r.entite, r.arrete FROM dbo.ref_arrete r
    JOIN dbo.ref_entite e ON e.code = r.entite AND e.forme_vehicule IS NOT NULL
    WHERE r.porte_balance = 1
), det AS (
    SELECT d.entite, d.arrete, d.famille, dbo.fn_compte_difference_estimation(d.poste_bilan) AS compte,
           COUNT(*) AS actifs, SUM(d.difference_estimation) AS difference
    FROM dbo.v_differences_detail d
    GROUP BY d.entite, d.arrete, d.famille, dbo.fn_compte_difference_estimation(d.poste_bilan)
), base AS (
    SELECT v.entite, v.arrete, f.famille, f.compte FROM veh v
    CROSS JOIN (VALUES ('IMMEUBLE', '271'), ('TITRE', '275'), ('COMPTE_COURANT', '276'), ('INSTRUMENT', '37')) f (famille, compte)
    UNION
    SELECT d.entite, d.arrete, d.famille, d.compte FROM det d JOIN veh v ON v.entite = d.entite AND v.arrete = d.arrete
)
SELECT b.entite, b.arrete, CAST(b.compte AS VARCHAR (20)) AS compte, b.famille, fa.libelle_court AS famille_libelle,
       ce.compte_contrepartie AS contrepartie,
       CAST(ISNULL(d.actifs, 0) AS INT)                                        AS actifs,
       CAST(ISNULL(d.difference, 0) AS DECIMAL (19,2))                         AS difference_actifs,
       CAST(ISNULL(bal.od_valorisation, 0) AS DECIMAL (19,2))                  AS od_valorisation,
       CAST(ISNULL(bal.balance_finale, 0) AS DECIMAL (19,2))                   AS solde_compte,
       CAST(ISNULL(d.difference, 0) - ISNULL(bal.balance_finale, 0) AS DECIMAL (19,2)) AS reste_a_passer,
       CAST(CASE WHEN d.actifs IS NULL THEN N'aucun actif'
                 WHEN ABS(ISNULL(d.difference, 0) - ISNULL(bal.balance_finale, 0)) < 0.005 THEN N'concorde'
                 ELSE N'à passer' END AS NVARCHAR (20))                       AS etat,
       b.entite + '|' + b.arrete + '|' + b.compte                              AS cle_ecran
FROM base b
LEFT JOIN det d ON d.entite = b.entite AND d.arrete = b.arrete AND d.famille = b.famille AND d.compte = b.compte
LEFT JOIN dbo.v_famille_actif fa ON fa.famille = b.famille
LEFT JOIN dbo.ref_contrepartie_estimation ce ON ce.compte_estimation = b.compte
LEFT JOIN dbo.v_balance bal ON bal.entite = b.entite AND bal.arrete = b.arrete AND bal.compte = b.compte;

GO

