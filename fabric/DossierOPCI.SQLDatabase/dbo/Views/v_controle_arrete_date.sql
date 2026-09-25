
-- 3b : un arrete dont la date derivee contredit son code.
CREATE   VIEW dbo.v_controle_arrete_date AS
SELECT entite, arrete, date_arrete,
       CONVERT(VARCHAR (10), date_arrete, 23) AS date_rendue
FROM dbo.ref_arrete
WHERE CONVERT(VARCHAR (10), date_arrete, 23) <> LEFT(arrete, 10);

GO

