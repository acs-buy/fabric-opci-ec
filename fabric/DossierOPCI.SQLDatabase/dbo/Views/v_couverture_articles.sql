

-- ---------------------------------------------------------------------
-- BLOC 6 : la vue de couverture, sur la seule source ANC (97 articles du
-- reglement ANC n° 2021-09 modifie par le reglement ANC n° 2024-01).
-- ---------------------------------------------------------------------
CREATE VIEW dbo.v_couverture_articles AS
SELECT a.article,
       a.intitule,
       a.titre,
       a.dans_perimetre,
       COUNT(q.question_id)                       AS nb_questions,
       CASE WHEN a.dans_perimetre = 0 AND COUNT(q.question_id) > 0
                                          THEN 'HORS_PERIMETRE_RATTACHE'
            WHEN a.dans_perimetre = 0    THEN 'HORS_PERIMETRE'
            WHEN COUNT(q.question_id) > 0 THEN 'COUVERT'
            ELSE 'TROU' END                       AS statut
FROM dbo.ref_article a
LEFT JOIN dbo.ref_question_article q ON q.article = a.article
WHERE a.source = 'ANC'
GROUP BY a.article, a.intitule, a.titre, a.dans_perimetre, a.ordre;

GO

