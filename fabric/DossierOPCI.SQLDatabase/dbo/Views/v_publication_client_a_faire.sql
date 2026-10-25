-- La file du pipeline publier_rapport_client ecarte les dossiers d'essai : un visa de cloture pose sur un essai ne
-- declenche plus de publication (garde-fou durable, 19/10/2026 ; publication_client n° 7 du 18/10/2026).
CREATE   VIEW dbo.v_publication_client_a_faire AS
SELECT a.cle_arrete, a.entite, a.arrete, a.visa_cloture_id, a.cloture_visee_par, a.cloture_visee_le
FROM dbo.v_arrete_client a
WHERE NOT EXISTS (SELECT 1 FROM dbo.publication_client p
                  WHERE p.entite = a.entite AND p.arrete = a.arrete
                    AND p.visa_id = a.visa_cloture_id AND p.etat IN ('EN_COURS', 'PUBLIEE'))
  AND NOT EXISTS (SELECT 1 FROM dbo.ref_entite e WHERE e.code = a.entite AND e.est_essai = 1);

GO

