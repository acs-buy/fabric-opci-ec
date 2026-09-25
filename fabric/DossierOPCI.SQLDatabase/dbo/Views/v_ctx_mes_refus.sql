CREATE   VIEW dbo.v_ctx_mes_refus AS
SELECT t.* FROM dbo.v_ecran_mes_refus t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p WHERE p.entite = t.entite AND p.arrete = t.arrete);

GO

