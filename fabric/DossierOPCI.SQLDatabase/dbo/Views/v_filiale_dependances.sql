-- --- 2. ce que porte chaque filiale, ou chaque lien quand l'entite reste -------------------------------
-- reste = 1 quand la filiale est cliente du cabinet ou tenue par un autre vehicule : le retrait ne touche que le
-- lien, et chaque compte se juge sur le lien. reste = 0 : comptes, statut et colonnes inchanges.
CREATE   VIEW dbo.v_filiale_dependances AS
SELECT ep.entite_mere, ep.entite_fille, e.denomination, e.forme_sociale, ep.droits_de_vote, ep.controlee,
       n.arretes, n.feuilles, n.pieces, n.ecritures, n.comptes, n.detentions,
       (SELECT COUNT(*) FROM dbo.role_mission r WHERE r.entite = ep.entite_fille) AS roles,
       CAST(CASE WHEN n.arretes = 0 AND n.feuilles = 0 AND n.pieces = 0 AND n.ecritures = 0 AND n.comptes = 0
                      AND n.detentions = 0
                      -- quand la ligne d'entite partirait, aucune autre donnee ne la reference
                      AND (s.reste = 1 OR NOT EXISTS (SELECT 1 FROM dbo.v_entite_donnees v WHERE v.entite = ep.entite_fille))
                 THEN 1 ELSE 0 END AS BIT) AS supprimable,
       ep.entite_mere + '|' + ep.entite_fille AS cle_ecran
FROM dbo.eligibilite_participation ep
JOIN dbo.ref_entite e ON e.code = ep.entite_fille
CROSS APPLY (SELECT CASE WHEN e.est_client = 1
                           OR EXISTS (SELECT 1 FROM dbo.eligibilite_participation o
                                      WHERE o.entite_fille = ep.entite_fille AND o.entite_mere <> ep.entite_mere)
                         THEN 1 ELSE 0 END AS reste) s
CROSS APPLY (
    SELECT
      CASE WHEN s.reste = 0
           THEN (SELECT COUNT(*) FROM dbo.ref_arrete a WHERE a.entite = ep.entite_fille
                    AND (a.nature_technique <> 'HORS_MISSION'
                         OR EXISTS (SELECT 1 FROM dbo.v_arrete_travail t WHERE t.entite = a.entite AND t.arrete = a.arrete)))
           ELSE (SELECT COUNT(*) FROM dbo.fn_lien_arretes(ep.entite_mere, ep.entite_fille) la
                 WHERE la.compte = 1 AND EXISTS (SELECT 1 FROM dbo.v_arrete_travail t WHERE t.entite = ep.entite_fille AND t.arrete = la.arrete))
      END AS arretes,
      CASE WHEN s.reste = 0
           THEN (SELECT COUNT(*) FROM dbo.feuille_travail f WHERE f.entite = ep.entite_fille)
           ELSE (SELECT COUNT(*) FROM dbo.feuille_travail f WHERE f.entite = ep.entite_fille
                    AND f.arrete IN (SELECT la.arrete FROM dbo.fn_lien_arretes(ep.entite_mere, ep.entite_fille) la WHERE la.compte = 1))
      END AS feuilles,
      CASE WHEN s.reste = 0
           THEN (SELECT COUNT(*) FROM dbo.piece_rattachement p WHERE p.entite = ep.entite_fille OR p.entite_couverte = ep.entite_fille)
           ELSE (SELECT COUNT(*) FROM dbo.piece_rattachement p
                 WHERE (p.entite = ep.entite_mere AND p.entite_couverte = ep.entite_fille)
                    OR (p.entite = ep.entite_fille
                        AND p.arrete IN (SELECT la.arrete FROM dbo.fn_lien_arretes(ep.entite_mere, ep.entite_fille) la WHERE la.compte = 1))
                    OR (p.entite_couverte = ep.entite_fille
                        AND p.arrete_couvert IN (SELECT la.arrete FROM dbo.fn_lien_arretes(ep.entite_mere, ep.entite_fille) la WHERE la.compte = 1)))
      END AS pieces,
      CASE WHEN s.reste = 0
           THEN (SELECT COUNT(*) FROM dbo.ecriture_axe x WHERE x.entite = ep.entite_fille)
              + (SELECT COUNT(*) FROM dbo.lot_ecritures l WHERE l.entite = ep.entite_fille)
              + (SELECT COUNT(*) FROM dbo.import_fec i WHERE i.entite = ep.entite_fille)
           ELSE (SELECT COUNT(*) FROM dbo.ecriture_axe x
                 JOIN dbo.ecriture w ON w.id = x.ecriture_id
                 JOIN dbo.lot_ecritures l ON l.id = w.lot_id
                 WHERE x.entite = ep.entite_fille AND l.entite = ep.entite_fille
                   AND l.arrete IN (SELECT la.arrete FROM dbo.fn_lien_arretes(ep.entite_mere, ep.entite_fille) la WHERE la.compte = 1))
              + (SELECT COUNT(*) FROM dbo.lot_ecritures l WHERE l.entite = ep.entite_fille
                    AND l.arrete IN (SELECT la.arrete FROM dbo.fn_lien_arretes(ep.entite_mere, ep.entite_fille) la WHERE la.compte = 1))
              + (SELECT COUNT(*) FROM dbo.import_fec i WHERE i.entite = ep.entite_fille
                    AND i.arrete IN (SELECT la.arrete FROM dbo.fn_lien_arretes(ep.entite_mere, ep.entite_fille) la WHERE la.compte = 1))
      END AS ecritures,
      CASE WHEN s.reste = 0
           THEN (SELECT COUNT(*) FROM dbo.ref_compte_entite c WHERE c.entite = ep.entite_fille OR c.entite_liee = ep.entite_fille)
           ELSE (SELECT COUNT(*) FROM dbo.ref_compte_entite c
                 WHERE (c.entite = ep.entite_mere AND c.entite_liee = ep.entite_fille)
                    OR (c.entite = ep.entite_fille AND c.entite_liee = ep.entite_mere))
      END AS comptes,
      CASE WHEN s.reste = 0
           THEN (SELECT COUNT(*) FROM dbo.detention d WHERE d.entite_fille = ep.entite_fille)
           ELSE (SELECT COUNT(*) FROM dbo.detention d WHERE d.entite_mere = ep.entite_mere AND d.entite_fille = ep.entite_fille)
      END AS detentions
) n;

GO

