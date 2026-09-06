
-- --- 5 : les controles ----------------------------------------------
-- C30 : un rejet de ligne dont le numero ne figure pas au transit. Il
-- designerait une ligne qui n'existe pas. ATTENDU zero, tant que le
-- transit n'est pas vide ; une fois vide, la vue ne peut plus le dire.
CREATE   VIEW dbo.v_controle_rejet_ligne_absente AS
SELECT r.id, r.import_id, r.numero_ligne, r.motif
FROM dbo.rejet_import r
WHERE r.nature = 'LIGNE'
  AND EXISTS (SELECT 1 FROM dbo.stg_balance s WHERE s.import_id = r.import_id)
  AND NOT EXISTS (SELECT 1 FROM dbo.stg_balance s
                  WHERE s.import_id = r.import_id
                    AND s.numero_ligne = r.numero_ligne);

GO

