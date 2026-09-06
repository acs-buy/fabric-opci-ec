

-- --- 9 : les controles ----------------------------------------------
-- C61 : un document produit sur un arrete dont l'etape 5 n'est pas
-- cloturee. La procedure l'interdit ; la vue le mesure. ATTENDU zero.
CREATE   VIEW dbo.v_controle_document_hors_cloture AS
SELECT d.entite, d.arrete, d.livrable, d.version, d.produit_le
FROM dbo.document_produit d
WHERE NOT EXISTS (SELECT 1 FROM dbo.visa v
                  WHERE v.nature = 'CLOTURE' AND v.entite = d.entite
                    AND v.arrete = d.arrete AND v.decision = 'VISE');

GO

