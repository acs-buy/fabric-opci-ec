
-- ------------------------------------------------------------------ n° 20 : les feuilles et derogations de la valorisation
-- Une ligne par feuille VALO et PART du vehicule et de ses filiales : la conclusion en attente de visa (v_a_viser) et la
-- derogation en cours (non levee), avec son visa en libelle.
CREATE   VIEW dbo.v_ecran_feuilles_valorisation AS
SELECT pv.vehicule, f.arrete, f.entite, f.cote, f.cycle,
       CAST(CASE WHEN c.objet_ref IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS conclusion_a_viser,
       CAST(CASE WHEN c.objet_ref IS NULL THEN NULL
                 WHEN f.forme_conclusion = 'AVEC_OBSERVATION' THEN N'avec observation'
                 WHEN f.forme_conclusion = 'SANS_OBSERVATION' THEN N'sans observation' END AS NVARCHAR (20)) AS conclusion_libelle,
       c.propose_par                                   AS conclusion_proposee_par,
       CAST(c.propose_le AS DATETIME2 (0))             AS conclusion_proposee_le,
       dg.id                                           AS derogation_id,
       dg.motif                                        AS derogation_motif,
       dg.accordee_par                                 AS derogation_proposee_par,
       CAST(dg.accordee_le AS DATETIME2 (0))           AS derogation_proposee_le,
       CAST(CASE WHEN dg.id IS NULL THEN NULL WHEN vd.decision = 'VISE' THEN N'visée' ELSE N'à viser' END AS NVARCHAR (10)) AS derogation_visa,
       pv.vehicule + '|' + f.cote                      AS cle_ecran
FROM dbo.feuille_travail f
JOIN dbo.v_perimetre_vehicule pv ON pv.entite = f.entite AND pv.arrete = f.arrete
LEFT JOIN dbo.v_a_viser c ON c.nature = 'CONCLUSION' AND c.objet_ref = f.cote
OUTER APPLY (SELECT TOP (1) d.id, d.motif, d.accordee_par, d.accordee_le FROM dbo.derogation d
             WHERE d.cote = f.cote AND d.levee_le IS NULL ORDER BY d.id DESC) dg
OUTER APPLY (SELECT TOP (1) x.decision FROM dbo.visa x
             WHERE x.nature = 'DEROGATION' AND x.objet_ref = CAST(dg.id AS VARCHAR (30)) ORDER BY x.decide_le DESC, x.id DESC) vd
WHERE f.cycle IN ('VALO', 'PART');

GO

