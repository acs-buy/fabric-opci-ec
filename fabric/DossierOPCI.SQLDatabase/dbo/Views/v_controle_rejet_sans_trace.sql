-- C28 : un import rejete qui n'a laisse aucune trace dans la table des
-- rejets. Le motif du refus serait perdu. ATTENDU zero.
CREATE   VIEW dbo.v_controle_rejet_sans_trace AS
SELECT i.id AS import_id, i.entite, i.arrete, i.nom_fichier, i.statut
FROM dbo.import_fec i
WHERE i.statut = 'REJETE'
  AND NOT EXISTS (SELECT 1 FROM dbo.rejet_import r WHERE r.import_id = i.id);

GO

