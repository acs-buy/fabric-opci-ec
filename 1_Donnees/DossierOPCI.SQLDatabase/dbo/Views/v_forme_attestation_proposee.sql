

-- --- 3 : la forme proposee, quand rien n'est derivable --------------
-- Elle ne rend plus NULL : elle nomme les 2 formes que les paragraphes
-- 20 et 21 admettent, et dit pourquoi la troisieme est fermee.
CREATE   VIEW dbo.v_forme_attestation_proposee AS
SELECT r.entite, r.arrete,
       COUNT(f.cote)                       AS feuilles,
       COUNT(f.forme_conclusion)           AS feuilles_conclues,
       SUM(CASE WHEN f.forme_conclusion = 'REFUS_ATTESTER' THEN 1 ELSE 0 END)
                                           AS en_refus,
       SUM(CASE WHEN f.forme_conclusion = 'AVEC_OBSERVATION' THEN 1 ELSE 0 END)
                                           AS avec_observation,
       CASE WHEN COUNT(f.forme_conclusion) = 0 THEN NULL
            WHEN SUM(CASE WHEN f.forme_conclusion = 'REFUS_ATTESTER'
                          THEN 1 ELSE 0 END) > 0 THEN 'REFUS_ATTESTER'
            WHEN SUM(CASE WHEN f.forme_conclusion = 'AVEC_OBSERVATION'
                          THEN 1 ELSE 0 END) > 0 THEN 'AVEC_OBSERVATION'
            ELSE 'SANS_OBSERVATION' END     AS forme_proposee,
       -- Les formes que l'expert-comptable peut arreter.
       CASE WHEN COUNT(f.forme_conclusion) = 0
            THEN N'AVEC_OBSERVATION, REFUS_ATTESTER'
            ELSE CASE WHEN SUM(CASE WHEN f.forme_conclusion = 'REFUS_ATTESTER'
                                    THEN 1 ELSE 0 END) > 0
                      THEN 'REFUS_ATTESTER'
                      WHEN SUM(CASE WHEN f.forme_conclusion = 'AVEC_OBSERVATION'
                                    THEN 1 ELSE 0 END) > 0
                      THEN 'AVEC_OBSERVATION'
                      ELSE 'SANS_OBSERVATION' END END AS formes_admises,
       CAST(CASE WHEN COUNT(f.forme_conclusion) = 0 THEN 1 ELSE 0 END AS BIT)
                                           AS limitation_des_diligences,
       CASE WHEN COUNT(f.forme_conclusion) = 0
            THEN N'aucune feuille de cycle n''est conclue : la forme ne se dérive pas, l''expert-comptable la choisit entre l''observation du paragraphe 20 et le refus d''attester du paragraphe 21, selon l''importance qu''il donne à la limitation de ses diligences. La forme sans observation est fermée.'
            WHEN COUNT(f.cote) > COUNT(f.forme_conclusion)
            THEN N'des feuilles restent à conclure : la forme proposée peut encore changer'
            ELSE N'toutes les feuilles sont conclues : la forme proposée est stable'
            END                             AS lecture,
       N'NP 2300 paragraphe 18 pour les 3 formes, paragraphe 20 pour l''observation en cas de limitation des diligences, paragraphe 21 pour le refus d''attester'
                                           AS source
FROM dbo.ref_arrete r
LEFT JOIN dbo.feuille_travail f ON f.entite = r.entite AND f.arrete = r.arrete
                               AND f.cycle IS NOT NULL
WHERE r.nature_technique = 'MISSION'
GROUP BY r.entite, r.arrete;

GO

