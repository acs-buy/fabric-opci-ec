CREATE   VIEW dbo.v_ctx_rejets_import AS
SELECT t.* FROM dbo.v_ecran_rejets_import t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p WHERE p.entite = t.entite);

GO

