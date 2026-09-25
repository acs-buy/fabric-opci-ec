CREATE   VIEW dbo.v_ctx_fec_a_exporter AS
SELECT t.* FROM dbo.v_ecran_fec_a_exporter t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p WHERE p.entite = t.entite AND p.arrete = t.arrete);

GO

