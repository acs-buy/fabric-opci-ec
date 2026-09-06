

-- ---------------------------------------------------------------------
-- BLOC 4 : v_lot_non_regenerable, les lots dont la correction passe par
-- une écriture inverse. SEULE DANS SON LOT.
-- ATTENDU sur une base reconstruite : 0 ligne.
-- ---------------------------------------------------------------------
CREATE   VIEW dbo.v_lot_non_regenerable AS
SELECT
    l.id      AS lot_id,
    l.arrete  AS arrete,
    l.entite  AS entite,
    l.famille AS famille,
    l.statut  AS statut,
    CASE l.statut WHEN 'EXPORTE' THEN 'ECRITURE_INVERSE_APRES_EXPORT'
                  ELSE 'ECRITURE_INVERSE_APRES_PUBLICATION'
    END       AS motif,
    (SELECT MAX(el.export_id) FROM dbo.export_fec_lot AS el
      WHERE el.lot_id = l.id) AS dernier_export_id
FROM dbo.lot_ecritures AS l
WHERE l.statut IN ('EXPORTE', 'PUBLIE');

GO

