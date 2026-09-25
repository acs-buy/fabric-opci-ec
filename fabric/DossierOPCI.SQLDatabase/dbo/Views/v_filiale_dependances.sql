
CREATE   VIEW dbo.v_filiale_dependances AS
SELECT ep.entite_mere, ep.entite_fille, e.denomination, e.forme_sociale, ep.droits_de_vote,
       (SELECT COUNT(*) FROM dbo.ref_arrete a WHERE a.entite = ep.entite_fille)                                   AS arretes,
       (SELECT COUNT(*) FROM dbo.feuille_travail f WHERE f.entite = ep.entite_fille)                              AS feuilles,
       (SELECT COUNT(*) FROM dbo.piece_rattachement p WHERE p.entite = ep.entite_fille OR p.entite_couverte = ep.entite_fille) AS pieces,
       (SELECT COUNT(*) FROM dbo.ecriture_axe x WHERE x.entite = ep.entite_fille)
     + (SELECT COUNT(*) FROM dbo.lot_ecritures l WHERE l.entite = ep.entite_fille)
     + (SELECT COUNT(*) FROM dbo.import_fec i WHERE i.entite = ep.entite_fille)                                    AS ecritures,
       (SELECT COUNT(*) FROM dbo.ref_compte_entite c WHERE c.entite = ep.entite_fille OR c.entite_liee = ep.entite_fille) AS comptes,
       (SELECT COUNT(*) FROM dbo.detention d WHERE d.entite_fille = ep.entite_fille)                              AS detentions,
       (SELECT COUNT(*) FROM dbo.role_mission r WHERE r.entite = ep.entite_fille)                                 AS roles,
       CAST(CASE WHEN NOT EXISTS (SELECT 1 FROM dbo.ref_arrete a WHERE a.entite = ep.entite_fille)
                  AND NOT EXISTS (SELECT 1 FROM dbo.feuille_travail f WHERE f.entite = ep.entite_fille)
                  AND NOT EXISTS (SELECT 1 FROM dbo.piece_rattachement p WHERE p.entite = ep.entite_fille OR p.entite_couverte = ep.entite_fille)
                  AND NOT EXISTS (SELECT 1 FROM dbo.ecriture_axe x WHERE x.entite = ep.entite_fille)
                  AND NOT EXISTS (SELECT 1 FROM dbo.lot_ecritures l WHERE l.entite = ep.entite_fille)
                  AND NOT EXISTS (SELECT 1 FROM dbo.import_fec i WHERE i.entite = ep.entite_fille)
                  AND NOT EXISTS (SELECT 1 FROM dbo.ref_compte_entite c WHERE c.entite = ep.entite_fille OR c.entite_liee = ep.entite_fille)
                  AND NOT EXISTS (SELECT 1 FROM dbo.detention d WHERE d.entite_fille = ep.entite_fille)
                 THEN 1 ELSE 0 END AS BIT) AS supprimable,
       ep.entite_mere + '|' + ep.entite_fille AS cle_ecran
FROM dbo.eligibilite_participation ep
JOIN dbo.ref_entite e ON e.code = ep.entite_fille;

GO

