-- C38 : un rattachement d'une piece permanente a un arrete qui n'est pas
-- le premier. Le verrou l'interdit ; la vue le detecte si le referentiel
-- des arretes change apres coup. ATTENDU zero.
CREATE   VIEW dbo.v_controle_permanent_hors_premier AS
SELECT r.id, r.piece_id, r.entite_couverte, r.arrete_couvert, a.libelle
FROM dbo.piece_rattachement r
JOIN dbo.ref_piece_attendue a ON a.id = r.piece_attendue_id
JOIN dbo.ref_arrete ar ON ar.entite = r.entite_couverte
                      AND ar.arrete = r.arrete_couvert
WHERE a.periodicite = 'PERMANENT'
  AND ar.date_arrete > (SELECT MIN(r2.date_arrete) FROM dbo.ref_arrete r2
                        WHERE r2.entite = r.entite_couverte
                          AND r2.porte_balance = 1);

GO

