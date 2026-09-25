CREATE   VIEW dbo.v_ctx_rationalisation_filiale AS
SELECT t.* FROM dbo.v_ecran_rationalisation_filiale t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p WHERE p.arrete = t.arrete);

GO

