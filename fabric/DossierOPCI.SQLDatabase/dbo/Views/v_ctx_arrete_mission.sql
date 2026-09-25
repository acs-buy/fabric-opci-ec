CREATE   VIEW dbo.v_ctx_arrete_mission AS
SELECT t.* FROM dbo.arrete_mission t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p WHERE p.entite = t.entite AND p.arrete = t.arrete);

GO

