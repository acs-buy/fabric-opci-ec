CREATE   VIEW dbo.v_ctx_bilan_actif AS
SELECT t.* FROM dbo.v_ecran_bilan_actif t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p WHERE p.entite = t.entite AND p.arrete = t.arrete);

GO

