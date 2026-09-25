
-- Les ecritures des lots du perimetre, a l'arrete choisi.
CREATE   VIEW dbo.v_ctx_ecriture AS
SELECT t.* FROM dbo.ecriture t
WHERE EXISTS (SELECT 1 FROM dbo.lot_ecritures l
              JOIN dbo.v_mon_perimetre p ON p.entite = l.entite AND p.arrete = l.arrete
              WHERE l.id = t.lot_id);

GO

