CREATE   VIEW dbo.v_ctx_ecriture_brouillon AS
SELECT t.* FROM dbo.ecriture_brouillon t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p WHERE p.entite = t.entite AND p.arrete = t.arrete);

GO

