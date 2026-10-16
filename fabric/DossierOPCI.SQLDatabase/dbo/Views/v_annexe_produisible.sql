
-- La production de l'annexe sur la derniere version (contrat, 4.2) : seul un obstacle en ecart la refuse.
CREATE   VIEW dbo.v_annexe_produisible AS
SELECT v.entite, v.arrete,
       x.cellules_a_remplir,
       0 AS bloquantes,
       x.tableaux,
       CAST(CASE WHEN n.obstacles = 0 THEN 1 ELSE 0 END AS BIT) AS produisible,
       CAST(ISNULL(oa.articles, '') AS VARCHAR (8000)) AS articles_fautifs,
       CAST(CASE WHEN n.obstacles = 0 THEN N'l''annexe peut être produite ; ' + CAST(x.cellules_a_remplir + x.en_attente AS NVARCHAR (10)) + N' case(s) vide(s) dans le Word'
                 ELSE N'l''annexe ne peut pas être produite : ' + oc.codes + N' en écart' END AS NVARCHAR (202)) AS lecture,
       x.en_attente,
       x.cellules_a_remplir + x.en_attente AS cases_vides,
       n.obstacles,
       CASE WHEN n.obstacles > 0 THEN dbo.fn_ann_message_obstacle(v.entite, v.arrete) END AS message_obstacle
FROM dbo.v_annexe_version v
CROSS APPLY (SELECT SUM(CAST(c.comptee AS INT)) AS cellules_a_remplir, SUM(CASE WHEN c.etat = 'EN_ATTENTE' THEN 1 ELSE 0 END) AS en_attente,
                    COUNT(DISTINCT c.article) AS tableaux
             FROM dbo.cellule_annexe c WHERE c.entite = v.entite AND c.arrete = v.arrete AND c.version = v.derniere_version) x
CROSS APPLY (SELECT COUNT(*) AS obstacles FROM dbo.controle_annexe k1
             WHERE k1.entite = v.entite AND k1.arrete = v.arrete AND k1.effet = 'obstacle' AND ABS(k1.ecart) > 0.005) n
CROSS APPLY (SELECT STRING_AGG(k.article, ', ') WITHIN GROUP (ORDER BY k.article) AS articles
             FROM (SELECT DISTINCT k1.article FROM dbo.controle_annexe k1
                   WHERE k1.entite = v.entite AND k1.arrete = v.arrete AND k1.effet = 'obstacle' AND ABS(k1.ecart) > 0.005) k) oa
CROSS APPLY (SELECT STRING_AGG(k.controle, ', ') WITHIN GROUP (ORDER BY k.controle) AS codes
             FROM (SELECT DISTINCT k1.controle FROM dbo.controle_annexe k1
                   WHERE k1.entite = v.entite AND k1.arrete = v.arrete AND k1.effet = 'obstacle' AND ABS(k1.ecart) > 0.005) k) oc
WHERE v.derniere_version IS NOT NULL;

GO

