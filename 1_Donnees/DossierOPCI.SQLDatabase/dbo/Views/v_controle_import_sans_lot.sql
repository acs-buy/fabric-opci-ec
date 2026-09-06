-- C31 : un import CHARGE qui ne porte aucun lot. Le chargement aurait
-- abouti sans rien produire. ATTENDU zero pour les imports charges par
-- procedure ; les 27 imports du jeu sont inscrits par le script 67, qui
-- ecrit les lots lui-meme, et ils en portent donc un.
CREATE   VIEW dbo.v_controle_import_sans_lot AS
SELECT i.id AS import_id, i.entite, i.arrete, i.format, i.statut
FROM dbo.import_fec i
WHERE i.statut = 'CHARGE'
  AND NOT EXISTS (SELECT 1 FROM dbo.lot_ecritures l WHERE l.import_id = i.id);

GO

