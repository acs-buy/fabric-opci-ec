
-- --- 4 : ce que le pipeline a a publier ---------------------------------
-- Un arrete est a publier quand son dernier visa de cloture est VISE et
-- qu'aucune publication reussie ni en cours ne porte ce visa : un nouveau visa
-- apres reouverture rouvre la file, une publication en echec aussi.
CREATE   VIEW dbo.v_publication_client_a_faire AS
SELECT a.cle_arrete, a.entite, a.arrete, a.visa_cloture_id, a.cloture_visee_par, a.cloture_visee_le
FROM dbo.v_arrete_client a
WHERE NOT EXISTS (SELECT 1 FROM dbo.publication_client p
                  WHERE p.entite = a.entite AND p.arrete = a.arrete
                    AND p.visa_id = a.visa_cloture_id AND p.etat IN ('EN_COURS', 'PUBLIEE'));

GO

