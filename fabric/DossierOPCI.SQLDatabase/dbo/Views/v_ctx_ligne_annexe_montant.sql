CREATE   VIEW dbo.v_ctx_ligne_annexe_montant AS
SELECT t.* FROM dbo.v_ecran_ligne_annexe_montant t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p WHERE p.entite = t.entite AND p.arrete = t.arrete);

GO

