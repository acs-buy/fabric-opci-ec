
CREATE   VIEW dbo.v_controle_sens_du_solde AS
WITH solde AS (
    SELECT e.entite, e.arrete, e.compte_ecrit,
           SUM(e.debit) - SUM(e.credit) AS solde
    FROM dbo.v_ecriture_normalisee e
    JOIN dbo.ref_arrete r ON r.entite = e.entite AND r.arrete = e.arrete
    WHERE e.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
      AND r.porte_balance = 1
      AND EXISTS (SELECT 1 FROM dbo.detention d
                  WHERE d.entite_fille = e.entite)
    GROUP BY e.entite, e.arrete, e.compte_ecrit
)
SELECT s.entite, s.arrete, s.compte_ecrit AS compte_num, s.solde,
       CASE WHEN s.solde > 0 THEN 'DEBIT'
            WHEN s.solde < 0 THEN 'CREDIT' ELSE 'NUL' END  AS sens_constate,
       dbo.fn_sens_attendu_au_plan(s.entite, s.compte_ecrit)
                                                           AS sens_attendu,
       CAST(CASE WHEN s.solde = 0 THEN 0
                 WHEN dbo.fn_sens_attendu_au_plan(s.entite, s.compte_ecrit)
                      = 'MIXTE' THEN 0
                 WHEN dbo.fn_sens_attendu_au_plan(s.entite, s.compte_ecrit)
                      = CASE WHEN s.solde > 0 THEN 'DEBIT' ELSE 'CREDIT' END
                 THEN 0 ELSE 1 END AS BIT)                 AS anomalie
FROM solde s;

GO

