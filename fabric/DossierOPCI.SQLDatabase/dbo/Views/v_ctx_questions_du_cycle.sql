CREATE   VIEW dbo.v_ctx_questions_du_cycle AS
SELECT t.* FROM dbo.v_ecran_questions_du_cycle t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p WHERE p.entite = t.entite AND p.arrete = t.arrete);

GO

