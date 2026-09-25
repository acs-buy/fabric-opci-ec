CREATE   VIEW dbo.v_ctx_evaluation_actif AS
SELECT t.* FROM dbo.evaluation_actif t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p WHERE p.entite = t.entite AND p.arrete = t.arrete);

GO

