-- C6 : un compte de difference derive qui n'est pas au plan de comptes,
-- ou qui n'a pas de contrepartie prescrite. ATTENDU zero.
CREATE   VIEW dbo.v_controle_compte_estimation_inconnu AS
SELECT DISTINCT compte_difference, compte_contrepartie
FROM dbo.v_nature_compte_estimation
WHERE compte_difference IS NOT NULL
  AND (compte_difference_libelle IS NULL OR compte_contrepartie IS NULL);

GO

