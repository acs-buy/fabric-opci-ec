
-- --- 2 : la vue des articles du code, pour lecture ------------------
-- Elle rend ce que la solution ancre sans le couvrir : le code fonde des
-- exigences, il n'est pas l'objet du controle de couverture.
CREATE   VIEW dbo.v_articles_du_code AS
SELECT a.article, a.intitule, a.ordre,
       CAST(0 AS BIT) AS entre_dans_la_couverture,
       (SELECT COUNT(*) FROM dbo.ref_question_article q
        WHERE q.article = a.article) AS questions_rattachees
FROM dbo.ref_article a
WHERE a.source = 'CMF';

GO

