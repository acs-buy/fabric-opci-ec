CREATE   VIEW dbo.v_ctx_a_viser_derogation AS
SELECT t.* FROM dbo.v_ecran_a_viser_derogation t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p WHERE p.entite = t.entite AND p.arrete = t.arrete);

GO

