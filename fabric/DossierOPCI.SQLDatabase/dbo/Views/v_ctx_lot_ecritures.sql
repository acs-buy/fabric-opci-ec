CREATE   VIEW dbo.v_ctx_lot_ecritures AS
SELECT t.* FROM dbo.lot_ecritures t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p WHERE p.entite = t.entite AND p.arrete = t.arrete);

GO

