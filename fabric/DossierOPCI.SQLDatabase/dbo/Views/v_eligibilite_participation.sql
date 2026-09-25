
-- --- 8 : la vue d'eligibilite, avec l'origine de la condition 2 -----
CREATE   VIEW dbo.v_eligibilite_participation AS
SELECT e.entite_mere, e.entite_fille, f.denomination,
       e.droits_de_vote,
       CAST(e.comptes_semestriels AS BIT)  AS condition_1_comptes,
       c2.condition_2                      AS condition_2_immeubles,
       c2.immeubles                        AS immeubles_de_la_societe,
       c2.a_qualifier                      AS immeubles_a_qualifier,
       c2.lecture                          AS condition_2_lecture,
       e.cas_relation                      AS condition_3_cas,
       c.libelle                           AS cas_libelle,
       CAST(c.maitrise AS BIT)             AS emporte_maitrise,
       -- Les 3 conditions sont CUMULATIVES.
       CAST(CASE WHEN e.comptes_semestriels = 1
                  AND c2.condition_2 = 1
                  AND e.cas_relation IS NOT NULL
                 THEN 1 ELSE 0 END AS BIT) AS eligible,
       -- Le bloc du tableau de l'article 336-2.
       CASE WHEN c.maitrise = 1 THEN N'Filiales ou participations contrôlées'
            WHEN c.maitrise = 0 THEN N'Filiales ou participations non contrôlées'
            ELSE N'à qualifier : le cas de relation n''est pas renseigné'
            END                            AS bloc_du_tableau_336_2,
       CASE WHEN e.comptes_semestriels <> 1
            THEN N'non éligible : la société n''établit pas de comptes intermédiaires au moins semestriels, condition 1'
            WHEN c2.condition_2 <> 1
            THEN N'non éligible, condition 2 : ' + c2.lecture
            WHEN e.cas_relation IS NULL
            THEN N'non éligible : aucun des 5 cas de relation du 3° n''est établi'
            WHEN c2.immeubles = 0
            THEN N'éligible, mais la condition 2 est satisfaite par vacuité : la société ne détient aucun immeuble'
            ELSE N'éligible : les 3 conditions cumulatives de l''article R. 214-83 sont satisfaites'
            END                            AS lecture,
       e.accord_ecrit_piece_id, e.qualifie_par, e.qualifie_le, e.note
FROM dbo.eligibilite_participation e
LEFT JOIN dbo.ref_entite f ON f.code = e.entite_fille
LEFT JOIN dbo.ref_cas_eligibilite c ON c.cas = e.cas_relation
LEFT JOIN dbo.v_condition_2_immeubles c2
       ON c2.entite_mere = e.entite_mere AND c2.entite_fille = e.entite_fille;

GO

