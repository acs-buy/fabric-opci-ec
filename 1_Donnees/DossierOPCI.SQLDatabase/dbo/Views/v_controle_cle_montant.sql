
-- 4c : une cle de montant dupliquee.
CREATE   VIEW dbo.v_controle_cle_montant AS
SELECT cle_montant, COUNT(*) AS occurrences
FROM dbo.v_montant_simulable_cle
GROUP BY cle_montant
HAVING COUNT(*) > 1;

GO

