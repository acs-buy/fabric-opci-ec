
-- Les livrables dus par arrete, et leur etat. La cloture de l'etape 5
-- les rend editables : avant elle, ils ne se produisent pas.
CREATE   VIEW dbo.v_livrables_dus AS
SELECT r.entite, r.arrete, r.type_arrete,
       l.ordre, l.code AS livrable, l.libelle, l.nature, l.article,
       CAST(CASE WHEN cl.id IS NOT NULL THEN 1 ELSE 0 END AS BIT)
                                           AS etape_5_cloturee,
       d.version                           AS derniere_version,
       d.produit_par, d.produit_le, d.perime_le, d.perime_motif,
       CASE WHEN cl.id IS NULL
            THEN N'l''étape 5 n''est pas clôturée : le livrable ne se produit pas encore'
            WHEN d.id IS NULL
            THEN N'à produire'
            WHEN d.perime_le IS NOT NULL
            THEN N'périmé : ' + LEFT(d.perime_motif, 120)
            ELSE N'produit le '
                 + FORMAT(d.produit_le, 'dd/MM/yyyy', 'fr-FR') END AS etat
FROM dbo.ref_arrete r
JOIN dbo.ref_livrable l
  ON l.applicable = 'LES_DEUX'
  OR (l.applicable = 'ARRETE_CLOTURE' AND r.type_arrete = 'ANNUEL')
  OR (l.applicable = 'ARRETE_VL' AND r.type_arrete <> 'ANNUEL')
OUTER APPLY (SELECT TOP 1 v.id FROM dbo.visa v
             WHERE v.nature = 'CLOTURE' AND v.entite = r.entite
               AND v.arrete = r.arrete AND v.decision = 'VISE') AS cl
OUTER APPLY (SELECT TOP 1 x.* FROM dbo.document_produit x
             WHERE x.entite = r.entite AND x.arrete = r.arrete
               AND x.livrable = l.code ORDER BY x.version DESC) AS d
WHERE r.nature_technique = 'MISSION';

GO

