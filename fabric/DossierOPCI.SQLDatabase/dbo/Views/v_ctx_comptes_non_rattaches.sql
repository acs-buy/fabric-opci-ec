CREATE   VIEW dbo.v_ctx_comptes_non_rattaches AS
SELECT t.* FROM dbo.v_ecran_comptes_non_rattaches t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p WHERE p.entite = t.entite);

GO

