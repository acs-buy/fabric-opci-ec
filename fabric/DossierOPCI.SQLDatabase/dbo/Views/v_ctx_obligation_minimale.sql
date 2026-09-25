CREATE   VIEW dbo.v_ctx_obligation_minimale AS
SELECT t.* FROM dbo.v_ecran_obligation_minimale t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p WHERE p.entite = t.entite);

GO

