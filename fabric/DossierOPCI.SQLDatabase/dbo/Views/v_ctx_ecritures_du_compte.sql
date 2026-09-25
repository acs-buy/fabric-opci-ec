CREATE   VIEW dbo.v_ctx_ecritures_du_compte AS
SELECT t.* FROM dbo.v_ecran_ecritures_du_compte t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p WHERE p.entite = t.entite AND p.arrete = t.arrete);

GO

