
-- C75 : une societe declaree eligible qui ne detient AUCUN immeuble.
-- Le controle ne conclut pas a un manquement : la condition 2 porte sur
-- les immeubles a l'actif, et l'absence d'immeuble ne l'enfreint pas. Il
-- pose une question au reviseur, celle de savoir si une societe sans
-- immeuble releve bien des 2° et 3° du I de l'article L. 214-36, qui
-- designent les societes dont les participations sont eligibles.
CREATE   VIEW dbo.v_controle_societe_eligible_sans_immeuble AS
SELECT v.entite_mere, v.entite_fille, v.denomination,
       N'la société est éligible au regard des 3 conditions de l''article R. 214-83, mais elle ne détient aucun immeuble : vérifier qu''elle relève des 2° et 3° du I de l''article L. 214-36'
                                                     AS lecture
FROM dbo.v_eligibilite_participation v
WHERE v.eligible = 1 AND v.immeubles_de_la_societe = 0;

GO

