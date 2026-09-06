
-- --- 6 : le perimetre de l'arrete, ecran E1-0 -----------------------
-- Une ligne par entite du perimetre, avec l'entree attendue et ce qui est
-- arrive. C'est le point V7 de la specification.
CREATE   VIEW dbo.v_perimetre_arrete AS
SELECT r.entite, r.arrete, r.date_arrete, r.exercice, r.type_arrete,
       r.nature_technique,
       e.denomination                                    AS entite_libelle,
       e.forme_vehicule, e.forme_sociale,
       -- L'entree attendue : une balance pour une filiale au PCG, le
       -- fichier des ecritures pour l'entite qui en produit un.
       CASE WHEN d.entite_fille IS NOT NULL THEN 'BALANCE' ELSE 'FEC' END
                                                         AS entree_attendue,
       CAST(CASE WHEN d.entite_fille IS NOT NULL THEN 1 ELSE 0 END AS BIT)
                                                         AS est_filiale,
       (SELECT COUNT(*) FROM dbo.import_fec i
        WHERE i.entite = r.entite AND i.arrete = r.arrete)
                                                         AS imports,
       (SELECT COUNT(*) FROM dbo.import_fec i
        WHERE i.entite = r.entite AND i.arrete = r.arrete
          AND i.statut = 'CHARGE')                       AS imports_charges,
       (SELECT COUNT(*) FROM dbo.import_fec i
        WHERE i.entite = r.entite AND i.arrete = r.arrete
          AND i.statut = 'REJETE')                       AS imports_rejetes,
       (SELECT COUNT(*) FROM dbo.lot_ecritures l
        WHERE l.entite = r.entite AND l.arrete = r.arrete)
                                                         AS lots,
       (SELECT COUNT(*) FROM dbo.ecriture ec
        JOIN dbo.lot_ecritures l ON l.id = ec.lot_id
        WHERE l.entite = r.entite AND l.arrete = r.arrete)
                                                         AS ecritures,
       CAST(r.porte_balance AS BIT)                      AS porte_balance,
       CASE WHEN r.porte_balance = 0 THEN 'HORS_BALANCE'
            WHEN NOT EXISTS (SELECT 1 FROM dbo.import_fec i
                             WHERE i.entite = r.entite AND i.arrete = r.arrete)
                 THEN 'RIEN_RECU'
            WHEN EXISTS (SELECT 1 FROM dbo.import_fec i
                         WHERE i.entite = r.entite AND i.arrete = r.arrete
                           AND i.statut = 'CHARGE')
                 THEN 'CHARGE'
            ELSE 'EN_ATTENTE' END                        AS etat_entree
FROM dbo.ref_arrete r
LEFT JOIN dbo.ref_entite e ON e.code = r.entite
LEFT JOIN (SELECT DISTINCT entite_fille FROM dbo.detention) d
       ON d.entite_fille = r.entite;

GO

