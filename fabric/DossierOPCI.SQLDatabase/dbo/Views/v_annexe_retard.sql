
-- La marque de retard par vehicule (contrat, 1.4) : depuis, origine de la derniere marque, nombre de marques, fin du
-- dernier calcul.
CREATE   VIEW dbo.v_annexe_retard AS
SELECT e.code AS entite,
       m.depuis, o.origine, ISNULL(m.ecritures, 0) AS ecritures, k.fin AS dernier_calcul,
       CAST(CASE WHEN ISNULL(m.ecritures, 0) > 0 THEN 1 ELSE 0 END AS BIT) AS en_retard
FROM dbo.ref_entite e
OUTER APPLY (SELECT MIN(r.ecrit_le) AS depuis, COUNT(*) AS ecritures, MAX(r.id) AS dernier_id FROM dbo.annexe_retard r WHERE r.entite = e.code) m
OUTER APPLY (SELECT r.origine FROM dbo.annexe_retard r WHERE r.id = m.dernier_id) o
OUTER APPLY (SELECT TOP (1) ca.fin FROM dbo.calcul_annexe ca WHERE ca.entite = e.code AND ca.fin IS NOT NULL ORDER BY ca.calcul_id DESC) k
WHERE e.forme_vehicule IS NOT NULL;

GO

