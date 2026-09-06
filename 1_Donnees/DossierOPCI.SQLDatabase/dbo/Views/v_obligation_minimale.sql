
-- --- 2 : l'obligation minimale, somme des categories --------------------
CREATE   VIEW dbo.v_obligation_minimale AS
SELECT entite, exercice,
       CAST(SUM(montant) AS DECIMAL (19,2)) AS obligation_minimale,
       COUNT(*) AS categories_renseignees
FROM dbo.obligation_distribution
GROUP BY entite, exercice;

GO

