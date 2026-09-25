CREATE   VIEW dbo.v_supervision_cycle AS
WITH a_viser AS (
    SELECT entite, arrete, cycle, COUNT(*) AS a_viser
    FROM dbo.v_a_viser GROUP BY entite, arrete, cycle
),
decides AS (
    SELECT entite, arrete, cycle,
           COUNT(*)                                              AS decisions,
           SUM(CASE WHEN decision = 'VISE' THEN 1 ELSE 0 END)     AS vises,
           MAX(decide_le)                                         AS derniere_decision
    FROM dbo.visa GROUP BY entite, arrete, cycle
),
-- Un renvoi EN COURS est le dernier mot sur son objet : s'il a ete suivi
-- d'un visa ou d'un nouveau renvoi, il n'est plus en cours.
renvois_en_cours AS (
    SELECT d.entite, d.arrete, d.cycle, COUNT(*) AS renvoyes
    FROM dbo.v_derniere_decision d
    WHERE d.decision = 'RENVOYE'
    GROUP BY d.entite, d.arrete, d.cycle
),
perimetre AS (
    SELECT entite, arrete, cycle FROM a_viser
    UNION SELECT entite, arrete, cycle FROM decides
    UNION SELECT entite, arrete, cycle FROM renvois_en_cours
    -- 06/09/2026, releve par la session des ecrans : un cycle sur lequel une feuille
    -- de travail existe mais qu'aucun visa ne touche encore n'entrait pas au perimetre,
    -- et le reviseur ne pouvait pas y entrer depuis la supervision. Le perimetre suit
    -- le travail reellement ouvert : les feuilles de cycle en font partie.
    UNION SELECT entite, arrete, cycle FROM dbo.feuille_travail WHERE cycle IS NOT NULL
)
SELECT p.entite, p.arrete, p.cycle,
       COALESCE(c.libelle, 'Arrete')                  AS cycle_libelle,
       COALESCE(c.ordre, 99)                          AS cycle_ordre,
       COALESCE(p.cycle, 'ARRETE')                    AS cycle_affiche,
       COALESCE(a.a_viser, 0)                         AS a_viser,
       COALESCE(d.vises, 0)                           AS vises,
       COALESCE(r.renvoyes, 0)                        AS renvoyes,
       COALESCE(d.decisions, 0)                       AS decisions,
       d.derniere_decision,
       (SELECT TOP (1) v.decide_par FROM dbo.visa v
        WHERE v.entite = p.entite AND v.arrete = p.arrete
          AND ((v.cycle = p.cycle) OR (v.cycle IS NULL AND p.cycle IS NULL))
        ORDER BY v.decide_le DESC)                    AS dernier_decideur,
       CASE WHEN COALESCE(r.renvoyes, 0) > 0 THEN 'RENVOIS EN COURS'
            WHEN COALESCE(a.a_viser, 0) > 0  THEN 'EN ATTENTE'
            WHEN COALESCE(d.decisions, 0) = 0 THEN 'OUVERT'
            ELSE 'A JOUR' END                         AS etat_cycle
FROM perimetre p
LEFT JOIN a_viser a ON a.entite = p.entite AND a.arrete = p.arrete
                   AND ((a.cycle = p.cycle) OR (a.cycle IS NULL AND p.cycle IS NULL))
LEFT JOIN decides d ON d.entite = p.entite AND d.arrete = p.arrete
                   AND ((d.cycle = p.cycle) OR (d.cycle IS NULL AND p.cycle IS NULL))
LEFT JOIN renvois_en_cours r ON r.entite = p.entite AND r.arrete = p.arrete
                   AND ((r.cycle = p.cycle) OR (r.cycle IS NULL AND p.cycle IS NULL))
LEFT JOIN dbo.ref_cycle c ON c.code = p.cycle;

GO

