
CREATE   VIEW dbo.v_livrables_dus AS
SELECT r.entite, r.arrete, r.type_arrete,
       l.ordre, l.code AS livrable, l.libelle, l.nature, l.article,
       -- le nom de colonne reste, lu par le modele : 1 quand l'arrete est valide pour le client (derniere decision)
       CAST(CASE WHEN cl.decision = 'VISE' THEN 1 ELSE 0 END AS BIT) AS etape_5_cloturee,
       d.version                           AS derniere_version,
       d.produit_par, d.produit_le, d.perime_le, d.perime_motif,
       CAST(CASE WHEN l.produit_etape_6 = 0 THEN N'hors du périmètre de production'
                 WHEN d.id IS NOT NULL AND d.perime_le IS NULL AND cl.decision = 'VISE'
                 THEN N'validé pour le client le ' + FORMAT(cl.decide_le, 'dd/MM/yyyy', 'fr-FR')
                 WHEN d.id IS NOT NULL AND d.perime_le IS NOT NULL THEN N'périmé : ' + LEFT(d.perime_motif, 120)
                 WHEN d.id IS NOT NULL THEN N'produit le ' + FORMAT(d.produit_le, 'dd/MM/yyyy', 'fr-FR')
                 WHEN dbo.fn_revue_visee(r.entite, r.arrete) = 0 THEN N'la revue n''est pas visée : le livrable ne se produit pas encore'
                 ELSE N'à produire' END AS NVARCHAR (200)) AS etat,
       r.message_ecran,
       l.produit_etape_6                   AS produit_a_l_etape_6
FROM dbo.ref_arrete r
JOIN dbo.ref_livrable l
  ON l.applicable = 'LES_DEUX'
  OR (l.applicable = 'ARRETE_CLOTURE' AND r.type_arrete = 'ANNUEL')
  OR (l.applicable = 'ARRETE_VL' AND r.type_arrete <> 'ANNUEL')
LEFT JOIN dbo.v_visa_cloture_courant cl ON cl.entite = r.entite AND cl.arrete = r.arrete
OUTER APPLY (SELECT TOP 1 x.* FROM dbo.document_produit x
             WHERE x.entite = r.entite AND x.arrete = r.arrete
               AND x.livrable = l.code ORDER BY x.version DESC, x.id DESC) AS d
WHERE r.nature_technique = 'MISSION';

GO

