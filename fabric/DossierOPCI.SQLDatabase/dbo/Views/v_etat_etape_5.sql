
-- L'etat de l'etape 5, que l'ecran E5-0 lit : ce qui manque avant la
-- cloture, dit avant le clic.
CREATE   VIEW dbo.v_etat_etape_5 AS
SELECT r.entite, r.arrete, r.type_arrete,
       CAST(CASE WHEN p.id IS NOT NULL THEN 1 ELSE 0 END AS BIT)
                                           AS vl_publiee,
       p.valeur_liquidative,
       CAST(CASE WHEN sy.id IS NOT NULL THEN 1 ELSE 0 END AS BIT)
                                           AS synthese_visee,
       fa.forme_proposee,
       a.forme                             AS forme_arretee,
       a.arretee_le,
       ob.categories, ob.visees            AS categories_visees,
       CAST(CASE WHEN cl.id IS NOT NULL THEN 1 ELSE 0 END AS BIT)
                                           AS cloturee,
       CASE
         WHEN cl.id IS NOT NULL THEN N'étape 5 clôturée'
         WHEN p.id IS NULL
           THEN N'la valeur liquidative n''est pas publiée'
         WHEN r.type_arrete = 'ANNUEL' AND COALESCE(ob.categories, 0)
              > COALESCE(ob.visees, 0)
           THEN N'des catégories de sommes distribuables ne sont pas visées'
         WHEN a.arretee_le IS NULL
           THEN N'la forme de l''attestation n''est pas arrêtée'
         ELSE N'tout est réuni : l''étape 5 peut être clôturée' END
                                           AS motif_du_refus
FROM dbo.ref_arrete r
OUTER APPLY (SELECT TOP 1 x.id, x.valeur_liquidative FROM dbo.publication_vl x
             WHERE x.entite = r.entite AND x.arrete = r.arrete
             ORDER BY x.id DESC) AS p
OUTER APPLY (SELECT TOP 1 v.id FROM dbo.visa v
             WHERE v.nature = 'SYNTHESE' AND v.entite = r.entite
               AND v.arrete = r.arrete AND v.decision = 'VISE') AS sy
OUTER APPLY (SELECT TOP 1 v.id FROM dbo.visa v
             WHERE v.nature = 'CLOTURE' AND v.entite = r.entite
               AND v.arrete = r.arrete AND v.decision = 'VISE') AS cl
LEFT JOIN dbo.v_forme_attestation_proposee fa ON fa.entite = r.entite
                                             AND fa.arrete = r.arrete
LEFT JOIN dbo.attestation a ON a.entite = r.entite AND a.arrete = r.arrete
OUTER APPLY (SELECT COUNT(*) AS categories,
                    SUM(CASE WHEN o.etat = 'VISEE' THEN 1 ELSE 0 END) AS visees
             FROM dbo.obligation_distribution o
             WHERE o.entite = r.entite
               AND YEAR(CONVERT(DATE, o.exercice))
                   = YEAR(CONVERT(DATE, r.arrete))) AS ob
WHERE r.nature_technique = 'MISSION';

GO

