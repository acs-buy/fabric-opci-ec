CREATE   VIEW dbo.v_ctx_saisie_annexe AS
SELECT t.* FROM dbo.saisie_annexe t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p WHERE p.entite = t.entite AND p.arrete = t.arrete);

GO

