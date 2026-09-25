
-- --- 5. la couverture de la balance ----------------------------------------------------------------
CREATE   VIEW dbo.v_couverture_balance AS
WITH cycles_du_compte AS (
    SELECT b.entite, b.arrete, b.compte, rc.cycle, rc.racine
    FROM dbo.v_balance b
    JOIN dbo.ref_cycle_compte rc ON b.compte LIKE rc.racine + '%'
),
actives AS (
    SELECT p.entite, p.arrete, pq.question_id, q.cycle
    FROM dbo.programme_travail p
    JOIN dbo.programme_question pq ON pq.programme_id = p.id AND pq.actif = 1
    JOIN dbo.ref_question q ON q.id = pq.question_id
)
SELECT b.entite, b.arrete, b.compte, b.libelle, b.balance_finale,
       (SELECT STRING_AGG(c.cycle, ', ') FROM (SELECT DISTINCT cycle FROM cycles_du_compte c
                                              WHERE c.entite = b.entite AND c.arrete = b.arrete AND c.compte = b.compte) c) AS cycles,
       (SELECT COUNT(*) FROM actives a JOIN dbo.ref_question_compte rq ON rq.question_id = a.question_id
         WHERE a.entite = b.entite AND a.arrete = b.arrete AND b.compte LIKE rq.racine + '%')       AS questions_directes,
       (SELECT COUNT(*) FROM actives a
         WHERE a.entite = b.entite AND a.arrete = b.arrete
           AND a.cycle IN (SELECT c.cycle FROM cycles_du_compte c
                           WHERE c.entite = b.entite AND c.arrete = b.arrete AND c.compte = b.compte)) AS questions_du_cycle,
       CAST(CASE WHEN NOT EXISTS (SELECT 1 FROM cycles_du_compte c
                                  WHERE c.entite = b.entite AND c.arrete = b.arrete AND c.compte = b.compte) THEN 'SANS_CYCLE'
                 WHEN EXISTS (SELECT 1 FROM actives a JOIN dbo.ref_question_compte rq ON rq.question_id = a.question_id
                              WHERE a.entite = b.entite AND a.arrete = b.arrete AND b.compte LIKE rq.racine + '%') THEN 'COUVERT'
                 WHEN EXISTS (SELECT 1 FROM actives a
                              WHERE a.entite = b.entite AND a.arrete = b.arrete
                                AND a.cycle IN (SELECT c.cycle FROM cycles_du_compte c
                                                WHERE c.entite = b.entite AND c.arrete = b.arrete AND c.compte = b.compte)) THEN 'COUVERT'
                 WHEN EXISTS (SELECT 1 FROM dbo.programme_travail p WHERE p.entite = b.entite AND p.arrete = b.arrete) THEN 'NON_COUVERT'
                 ELSE 'SANS_PROGRAMME' END AS VARCHAR (14)) AS etat
FROM dbo.v_balance b;

GO

