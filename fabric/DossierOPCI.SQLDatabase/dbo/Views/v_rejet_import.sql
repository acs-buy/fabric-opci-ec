
-- --- 4 : la vue des rejets, perenne et lisible ----------------------
-- Elle remplace dbo.v_rejets_import, qui lisait le transit et se vidait
-- avec lui. L'ancienne reste, d'autres objets pouvant la lire.
CREATE   VIEW dbo.v_rejet_import AS
SELECT r.id, r.import_id, i.entite, i.arrete, i.format, i.nom_fichier,
       i.statut                                           AS statut_import,
       r.nature, r.numero_ligne, r.compte_num, r.debit, r.credit,
       r.motif, r.geste, r.motif_arret, r.rejete_le,
       CAST(CASE WHEN r.nature = 'FICHIER' THEN 1 ELSE 0 END AS BIT)
           AS arrete_le_chargement
FROM dbo.rejet_import r
JOIN dbo.import_fec i ON i.id = r.import_id;

GO

