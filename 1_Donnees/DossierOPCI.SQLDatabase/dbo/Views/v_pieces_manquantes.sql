
-- Les 3 objets que la date d'effet borne. Le declencheur de la
-- conclusion et les 2 vues des pieces lisent desormais la date de
-- l'arrete de la feuille.
CREATE   VIEW dbo.v_pieces_manquantes AS
SELECT f.cote, f.entite, f.arrete, f.cycle,
       rpa.id                AS piece_attendue_id,
       rpa.libelle           AS piece_attendue,
       rpa.periodicite,
       CAST(rpa.obligatoire AS BIT) AS obligatoire
FROM dbo.feuille_travail f
JOIN dbo.ref_piece_attendue rpa ON rpa.cycle = f.cycle
WHERE rpa.obligatoire = 1
  AND rpa.periodicite IN ('ARRETE', 'PERMANENT')
  -- La piece attendue ne s'exige qu'a partir de sa date d'effet.
  AND (rpa.en_vigueur_depuis IS NULL
       OR rpa.en_vigueur_depuis <= CONVERT(DATE, f.arrete))
  AND NOT EXISTS (SELECT 1 FROM dbo.piece_rattachement pr
                  WHERE pr.piece_attendue_id = rpa.id
                    AND pr.entite = f.entite
                    AND (rpa.periodicite = 'PERMANENT'
                         OR pr.arrete = f.arrete));

GO

