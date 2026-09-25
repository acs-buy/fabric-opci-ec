CREATE   VIEW dbo.v_ctx_titres_valeur_actuelle AS
SELECT t.* FROM dbo.v_ecran_titres_valeur_actuelle t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p WHERE p.arrete = t.arrete);

GO

