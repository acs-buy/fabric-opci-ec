
-- --- depuis 63_SQL/73_cles_arrete.sql : v_controle_difference_titres -------------
-- --- 3-bis : le controle de concordance, borne aux arretes valorises --
-- Un arrete sans lot de valorisation n'a rien a concorder : l'ancien jeu
-- d'essai du script 42 en laissait un au 31/12/2023, avec un ecart de
-- 100,00 qui n'etait pas une divergence mais une absence. L'absence de
-- valorisation la ou elle est attendue releve d'un autre controle, a
-- ecrire avec la procedure de generation.
CREATE   VIEW dbo.v_controle_difference_titres AS
WITH valorises AS (
    SELECT DISTINCT l.entite, l.arrete
    FROM dbo.lot_ecritures l
    WHERE l.famille = 'DERIVABLE'
      AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
),
semee AS (
    SELECT l.entite, l.arrete,
           CAST(SUM(e.debit - e.credit) AS DECIMAL (19,2)) AS montant_seme
    FROM dbo.v_ecriture_normalisee e
    JOIN dbo.lot_ecritures l ON l.id = e.lot_id
    WHERE l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
      AND l.famille = 'DERIVABLE'
      AND e.compte_num LIKE '275%'
    GROUP BY l.entite, l.arrete
),
calculee AS (
    SELECT t.entite_mere AS entite, t.arrete,
           CAST(SUM(t.difference_estimation_titres) AS DECIMAL (19,2))
               AS montant_calcule
    FROM dbo.v_titres_valeur_actuelle t
    GROUP BY t.entite_mere, t.arrete
)
SELECT v.entite, v.arrete,
       COALESCE(s.montant_seme, 0)    AS montant_seme,
       COALESCE(c.montant_calcule, 0) AS montant_calcule,
       CAST(COALESCE(s.montant_seme, 0) - COALESCE(c.montant_calcule, 0)
            AS DECIMAL (19,2)) AS ecart
FROM valorises v
LEFT JOIN semee s ON s.entite = v.entite AND s.arrete = v.arrete
LEFT JOIN calculee c ON c.entite = v.entite AND c.arrete = v.arrete
WHERE ABS(COALESCE(s.montant_seme, 0) - COALESCE(c.montant_calcule, 0)) > 0.00;

GO

