CREATE   VIEW dbo.v_ctx_simulation_distribution AS
SELECT t.* FROM dbo.v_ecran_simulation_distribution t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p WHERE p.entite = t.entite AND p.arrete = t.arrete);

GO

