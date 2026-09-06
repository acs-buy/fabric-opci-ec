-- C10 : un lot valide sans visa. Les 57 lots du jeu de demonstration ont
-- ete poses avant le lot F, donc directement au statut VALIDE : la vue
-- les compte, et c'est un fait a montrer, non une anomalie a masquer.
CREATE   VIEW dbo.v_controle_lot_valide_sans_visa AS
SELECT l.id, l.entite, l.arrete, l.famille, l.statut, l.cree_par, l.cree_le
FROM dbo.lot_ecritures l
WHERE l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
  AND NOT EXISTS (SELECT 1 FROM dbo.visa v
                  WHERE v.nature = 'LOT'
                    AND v.objet_ref = CAST(l.id AS VARCHAR (30)));

GO

