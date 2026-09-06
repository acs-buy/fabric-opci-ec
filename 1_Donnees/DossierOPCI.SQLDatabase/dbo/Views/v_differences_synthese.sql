
-- --- 4 : la synthese, avec la citation complete ---------------------
CREATE   VIEW dbo.v_differences_synthese AS
SELECT p.entite, p.arrete, p.exercice, p.famille,
       MIN(p.article)                                       AS article,
       MIN(p.norme)                                         AS norme,
       MIN(p.citation_courte)                               AS citation_courte,
       COUNT(*)                                             AS nombre_actifs,
       CAST(SUM(p.valeur_comptable) AS DECIMAL (19,2))       AS valeur_comptable,
       CAST(SUM(p.valeur_actuelle) AS DECIMAL (19,2))        AS valeur_actuelle,
       CAST(SUM(p.difference_estimation) AS DECIMAL (19,2))
           AS difference_estimation
FROM dbo.v_patrimoine_valorise p
GROUP BY p.entite, p.arrete, p.exercice, p.famille;

GO

