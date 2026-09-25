
-- --- 5 : l'unicite de la cle d'arrete. ATTENDU : zero ligne ------
CREATE   VIEW dbo.v_controle_cle_arrete AS
SELECT cle_arrete, COUNT(*) AS occurrences
FROM dbo.v_arrete_client
GROUP BY cle_arrete
HAVING COUNT(*) > 1;

GO

