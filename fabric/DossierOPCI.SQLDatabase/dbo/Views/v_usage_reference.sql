
-- --- 9 : la vue de l'usage des references, pour le reviseur --------
-- Elle repond a la question « si je change cette reference, qu'est-ce qui
-- bouge ? ». C'est ce que le candidat a demande : une table ou l'on change
-- une reference et ou l'on voit ce que cela met a jour.
CREATE   VIEW dbo.v_usage_reference AS
SELECT r.id, r.norme, r.reference, r.citation_courte, r.intitule,
       CAST(r.lu_sur_piece AS BIT)                    AS lu_sur_piece,
       (SELECT COUNT(*) FROM dbo.ref_nature_actif n WHERE n.reference_id = r.id)
                                                      AS natures_d_actif,
       (SELECT COUNT(*) FROM dbo.ref_contrepartie_estimation c
        WHERE c.reference_id = r.id)                  AS contreparties,
       (SELECT COUNT(*) FROM dbo.ref_compte c WHERE c.reference_id = r.id)
                                                      AS comptes,
       (SELECT COUNT(*) FROM dbo.ref_forme_conclusion f
        WHERE f.reference_id = r.id)                  AS formes_de_conclusion,
       (SELECT COUNT(*) FROM dbo.ref_question_article q
        WHERE q.article = r.reference)                AS questions_de_feuille,
       (SELECT COUNT(*) FROM dbo.v_patrimoine_valorise p
        WHERE p.norme = r.norme AND p.reference = r.reference)
                                                      AS lignes_de_patrimoine
FROM dbo.v_reference r;

GO

