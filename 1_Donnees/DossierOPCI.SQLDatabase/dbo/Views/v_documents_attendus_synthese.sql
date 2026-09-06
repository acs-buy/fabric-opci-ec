
-- --- 2 : la synthese par entite et arrete, ecran E1-B ---------------
CREATE   VIEW dbo.v_documents_attendus_synthese AS
SELECT entite, arrete, date_arrete,
       COUNT(*)                                              AS exigences,
       SUM(CASE WHEN etat = 'FOURNIE' THEN 1 ELSE 0 END)      AS fournies,
       SUM(CASE WHEN etat = 'MANQUANTE' THEN 1 ELSE 0 END)    AS manquantes,
       SUM(CASE WHEN etat = 'FACULTATIVE' THEN 1 ELSE 0 END)  AS facultatives,
       CAST(CASE WHEN COUNT(*) = 0 THEN 0
                 ELSE SUM(CASE WHEN etat = 'FOURNIE' THEN 1 ELSE 0 END)
                      * 100.0 / COUNT(*) END AS DECIMAL (5,1))
                                                             AS taux_fourni
FROM dbo.v_documents_attendus
GROUP BY entite, arrete, date_arrete;

GO

