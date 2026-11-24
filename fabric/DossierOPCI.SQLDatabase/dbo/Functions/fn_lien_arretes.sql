-- --- 1. les arretes d'une filiale que porte son lien avec un vehicule ----------------------------------
-- Une ligne par arrete HORS_MISSION de @fille que le lien (@mere, @fille) concerne :
--   partage = 1 quand un autre vehicule de @fille tient un arrete a la meme date ; seuls les arretes non partages
--               partent avec le lien (pr_supprimer_filiale_corps) ;
--   compte  = 1 quand l'arrete se juge pour le lien : non partage, ou partage a une date ou @mere a ouvert son arrete
--               sans aucune detention (le perimetre de cet arrete se lit alors sur les liens,
--               fn_filiales_a_l_arrete, et le travail de la filiale y releve aussi de la mission de @mere ;
--               avec une detention a la date, le perimetre se lit sur detention seule et le lien est sans
--               effet sur l'arrete ; une detention de @mere sur @fille compte deja dans la colonne detentions).
-- Entite qui part (ni cliente du cabinet, ni tenue par un autre vehicule) : tous ses arretes HORS_MISSION, partage = 0,
-- compte = 1. Entite qui reste : seulement aux dates que @mere tient, et aucun
-- pour un client du cabinet, dont les arretes HORS_MISSION sont les siens.
CREATE   FUNCTION dbo.fn_lien_arretes (@mere VARCHAR (20), @fille VARCHAR (20))
RETURNS TABLE
AS RETURN
SELECT a.arrete, p.partage,
       CAST(CASE WHEN p.partage = 0
                   OR (EXISTS (SELECT 1 FROM dbo.arrete_mission am WHERE am.entite = @mere AND am.arrete = a.arrete)
                       AND NOT EXISTS (SELECT 1 FROM dbo.detention d WHERE d.entite_mere = @mere AND d.arrete = a.arrete))
                 THEN 1 ELSE 0 END AS BIT) AS compte
FROM dbo.ref_arrete a
JOIN dbo.ref_entite fe ON fe.code = a.entite
CROSS APPLY (SELECT CAST(CASE WHEN EXISTS (SELECT 1 FROM dbo.eligibilite_participation o
                                          JOIN dbo.ref_arrete r2 ON r2.entite = o.entite_mere AND r2.arrete = a.arrete
                                          WHERE o.entite_fille = @fille AND o.entite_mere <> @mere)
                              THEN 1 ELSE 0 END AS BIT) AS partage) p
WHERE a.entite = @fille AND a.nature_technique = 'HORS_MISSION'
  AND (   -- l'entite part : 
          (fe.est_client = 0
           AND NOT EXISTS (SELECT 1 FROM dbo.eligibilite_participation o WHERE o.entite_fille = @fille AND o.entite_mere <> @mere))
          -- l'entite reste : une date que le vehicule tient, hors client du cabinet
       OR (fe.est_client = 0
           AND EXISTS (SELECT 1 FROM dbo.ref_arrete m WHERE m.entite = @mere AND m.arrete = a.arrete)));

GO

