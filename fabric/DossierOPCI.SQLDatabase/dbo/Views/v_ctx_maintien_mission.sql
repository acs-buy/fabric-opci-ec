CREATE   VIEW dbo.v_ctx_maintien_mission AS
SELECT t.* FROM dbo.maintien_mission t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p WHERE p.entite = t.entite);

GO

