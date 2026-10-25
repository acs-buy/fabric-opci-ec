-- ecran 5, lot 1, script 324 (61_DEPLOIEMENT/generer_e5_324_questions.py) : genere, ne pas modifier a la main.
-- Objet n° 29 : le tableau croise « Questions de reference », une ligne par cycle et par phase, sans relation a la table
-- du segment ; genre en libelle et sa cle de tri genre_ordre ; ordre : celui de v_ecran_cycle_ou_phase (ordre de passage
-- des cycles, D19 de l'existant) ; repondues : questions dont au moins une feuille porte une reponse ; sans_niveau :
-- questions de cycle sans niveau de programme, vide pour une phase.
CREATE   VIEW dbo.v_ecran_questions_par_cycle AS
WITH q AS (
    SELECT CAST(CASE WHEN q.cycle IS NOT NULL THEN 'CYCLE' ELSE 'PHASE' END AS VARCHAR (5)) AS genre,
           ISNULL(q.cycle, q.phase) AS code, q.statut, q.niveau_programme,
           CASE WHEN EXISTS (SELECT 1 FROM dbo.feuille_question f WHERE f.question_id = q.id AND f.reponse IS NOT NULL)
                THEN 1 ELSE 0 END AS repondue
    FROM dbo.ref_question q
)
SELECT CAST(CASE cp.genre WHEN 'CYCLE' THEN N'Cycles, ordre de passage' ELSE N'Phases de la mission' END AS NVARCHAR (40)) AS genre,
       CAST(CASE cp.genre WHEN 'CYCLE' THEN 1 ELSE 2 END AS INT) AS genre_ordre,
       cp.code, cp.nom_usage, cp.ordre,
       CAST(COUNT(q.code) AS INT) AS questions,
       CAST(ISNULL(SUM(CASE WHEN q.statut = 'A_AUDITER' THEN 1 ELSE 0 END), 0) AS INT) AS a_auditer,
       CAST(ISNULL(SUM(CASE WHEN q.statut = 'VALIDEE' THEN 1 ELSE 0 END), 0) AS INT) AS validees,
       CAST(ISNULL(SUM(CASE WHEN q.statut = 'ECARTEE' THEN 1 ELSE 0 END), 0) AS INT) AS ecartees,
       CAST(ISNULL(SUM(q.repondue), 0) AS INT) AS repondues,
       CAST(CASE WHEN cp.genre = 'CYCLE'
                 THEN ISNULL(SUM(CASE WHEN q.code IS NOT NULL AND q.niveau_programme IS NULL THEN 1 ELSE 0 END), 0) END AS INT) AS sans_niveau
FROM dbo.v_ecran_cycle_ou_phase cp
LEFT JOIN q ON q.genre = cp.genre AND q.code = cp.code
GROUP BY cp.genre, cp.code, cp.nom_usage, cp.ordre;

GO

