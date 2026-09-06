
-- 3c : un exercice qui ne se termine pas a la cloture de son entite.
CREATE   VIEW dbo.v_controle_arrete_exercice AS
SELECT r.entite, r.arrete, r.exercice, r.date_cloture, e.cloture
FROM dbo.ref_arrete r
JOIN dbo.ref_entite e ON e.code = r.entite
WHERE CONVERT(VARCHAR (10), r.date_cloture, 23) <> r.exercice
   OR RIGHT('0' + CAST(DAY(r.date_cloture) AS VARCHAR (2)), 2) + '-'
      + RIGHT('0' + CAST(MONTH(r.date_cloture) AS VARCHAR (2)), 2) <> e.cloture;

GO

