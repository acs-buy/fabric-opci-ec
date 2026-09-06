
-- --- 3 : la valeur liquidative, organismes seuls, refus sans parts -----
-- vl = anr / nombre de parts, CAST final DECIMAL (19,2). L'ecart avec le
-- precedent arrete vient de LAG. Sans nombre de parts a l'arrete, la
-- valeur est NULL et le motif l'ecrit : elle ne se publie pas.
CREATE   VIEW dbo.v_valeur_liquidative AS
WITH calcul AS (
    SELECT a.entite, a.arrete, a.actif_net_reevalue,
           p.nombre_parts, p.source,
           v.version_regles,
           CASE WHEN p.nombre_parts IS NULL THEN NULL
                ELSE CAST(a.actif_net_reevalue / p.nombre_parts AS DECIMAL (19,2))
           END AS valeur_liquidative,
           CASE WHEN p.nombre_parts IS NULL
                THEN N'nombre de parts absent a l''arrete : valeur non publiable'
           END AS motif_refus
    FROM dbo.v_anr_entite a
    INNER JOIN dbo.ref_entite r ON r.code = a.entite
                               AND r.forme_vehicule IS NOT NULL
    LEFT JOIN dbo.parts_en_circulation p
           ON p.entite = a.entite AND p.arrete = a.arrete
    OUTER APPLY (SELECT TOP 1 l.version_regles
                 FROM dbo.lot_ecritures l
                 WHERE l.entite = a.entite AND l.arrete = a.arrete
                   AND l.famille = 'DERIVABLE'
                   AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
                 ORDER BY l.id DESC) v
)
SELECT entite, arrete, actif_net_reevalue, nombre_parts, source,
       version_regles, valeur_liquidative, motif_refus,
       LAG(valeur_liquidative) OVER (PARTITION BY entite ORDER BY arrete)
           AS valeur_liquidative_precedente,
       CAST(valeur_liquidative
          - LAG(valeur_liquidative) OVER (PARTITION BY entite ORDER BY arrete)
            AS DECIMAL (19,2)) AS ecart
FROM calcul;

GO

