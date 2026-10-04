
-- C88 : une entite porte un 275 non nul et detient des parts 252 ; le 275 n'etant pas subdivise, sa part des 252 est
-- comptee avec les 254. ATTENDU zero.
CREATE   VIEW dbo.v_controle_275_a_partager AS
WITH solde AS (
    SELECT lo.entite, lo.arrete,
           SUM(CASE WHEN e.compte_num LIKE '252%' THEN e.debit - e.credit ELSE 0 END) AS parts_252,
           SUM(CASE WHEN e.compte_num LIKE '275%' THEN e.debit - e.credit ELSE 0 END) AS difference_275
    FROM dbo.v_ecriture_normalisee e JOIN dbo.lot_ecritures lo ON lo.id = e.lot_id
    WHERE lo.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
    GROUP BY lo.entite, lo.arrete
)
SELECT s.entite, s.arrete, CAST(s.parts_252 AS DECIMAL (19, 2)) AS parts_252, CAST(s.difference_275 AS DECIMAL (19, 2)) AS difference_275,
       N'le compte 275 n''est pas subdivisé par alinéa : sa part relative aux parts 252 est présentée avec les parts 254 ; subdiviser le 275 pour la ranger avec les 252' AS lecture
FROM solde s
JOIN dbo.v_arrete_etat a ON a.entite = s.entite AND a.arrete = s.arrete
WHERE ABS(s.parts_252) > 0.005 AND ABS(s.difference_275) > 0.005;

GO

