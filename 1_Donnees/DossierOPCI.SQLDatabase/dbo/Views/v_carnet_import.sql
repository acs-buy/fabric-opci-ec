
-- --- 5 : le carnet d'import, tel que l'ecran E1-A le lit -------------
-- Il dit, par entite et par arrete, ce qui est entre, sous quel format,
-- avec quel exercice, et si un autre import couvre deja le meme
-- perimetre. C'est le point V8 de la specification.
CREATE   VIEW dbo.v_carnet_import AS
SELECT i.id AS import_id, i.entite, i.arrete, i.format, i.nom_fichier,
       i.empreinte, i.exercice_debut, i.exercice_fin,
       i.lignes_lues, i.lignes_rejetees, i.statut,
       i.importe_par, i.importe_le,
       c.exercice_conforme, c.motif_non_conforme,
       -- Un autre import deja charge sur le meme perimetre : la balance
       -- se remplacerait sans qu'on le sache.
       (SELECT COUNT(*) FROM dbo.import_fec j
        WHERE j.entite = i.entite AND j.arrete = i.arrete
          AND j.id <> i.id AND j.statut = 'CHARGE')      AS autres_charges,
       -- Les rejets perennes, qui survivent au vidage du transit.
       (SELECT COUNT(*) FROM dbo.rejet_import r WHERE r.import_id = i.id)
                                                         AS rejets_conserves,
       (SELECT COUNT(*) FROM dbo.rejet_import r
        WHERE r.import_id = i.id AND r.nature = 'FICHIER')
                                                         AS refus_du_fichier,
       -- Le lot que le chargement a produit, s'il a abouti.
       (SELECT TOP (1) l.id FROM dbo.lot_ecritures l WHERE l.import_id = i.id)
                                                         AS lot_id,
       (SELECT COUNT(*) FROM dbo.ecriture e
        JOIN dbo.lot_ecritures l ON l.id = e.lot_id
        WHERE l.import_id = i.id)                        AS ecritures_produites
FROM dbo.import_fec i
LEFT JOIN dbo.v_import_exercice_conforme c ON c.import_id = i.id;

GO

