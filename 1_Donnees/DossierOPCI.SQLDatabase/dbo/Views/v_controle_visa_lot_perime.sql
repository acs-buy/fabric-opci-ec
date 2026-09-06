-- C18 : un lot vise alors qu'il etait perime, sans motif de visa. Le
-- verrou l'interdit ; la vue le detecte si un visa a ete insere
-- directement. ATTENDU zero.
CREATE   VIEW dbo.v_controle_visa_lot_perime AS
SELECT v.id AS visa_id, v.objet_ref, v.decide_par, v.decide_le,
       l.perime_le, l.perime_motif
FROM dbo.visa v
JOIN dbo.lot_ecritures l ON l.id = TRY_CAST(v.objet_ref AS INT)
WHERE v.nature = 'LOT' AND v.decision = 'VISE'
  AND l.perime_le IS NOT NULL AND v.motif IS NULL;

GO

