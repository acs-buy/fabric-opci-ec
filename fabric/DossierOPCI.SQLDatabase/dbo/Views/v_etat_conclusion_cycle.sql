

-- UNE LIGNE PAR CYCLE AU PROGRAMME D'UN ARRETE DE MISSION D'UN VEHICULE. Feuilles, lots et objets a viser
-- sur le perimetre du vehicule (regle 0.7) ; questions sur le programme du vehicule.
CREATE   VIEW dbo.v_etat_conclusion_cycle AS
WITH base AS (
    SELECT p.entite, p.arrete, pc.cycle, c.libelle AS cycle_libelle, c.ordre AS cycle_ordre
    FROM dbo.programme_travail p
    JOIN dbo.ref_entite e ON e.code = p.entite AND e.forme_vehicule IS NOT NULL
    JOIN dbo.v_programme_cycles pc ON pc.programme_id = p.id AND pc.etat <> 'INACTIF'
    JOIN dbo.ref_cycle c ON c.code = pc.cycle
),
sup AS (
    SELECT pv.vehicule, s.arrete, s.cycle, SUM(s.a_viser) AS a_viser, SUM(s.vises) AS vises, SUM(s.renvoyes) AS renvoyes, SUM(s.decisions) AS decisions
    FROM dbo.v_supervision_cycle s JOIN dbo.v_perimetre_vehicule pv ON pv.entite = s.entite AND pv.arrete = s.arrete
    GROUP BY pv.vehicule, s.arrete, s.cycle
)
SELECT b.entite, b.arrete, b.cycle, b.entite + '|' + b.arrete + '|' + b.cycle AS cle_cycle, b.cycle_libelle, b.cycle_ordre,
       (SELECT COUNT(*) FROM dbo.v_questions_programme q WHERE q.entite = b.entite AND q.arrete = b.arrete AND q.cycle = b.cycle) AS questions,
       (SELECT COUNT(*) FROM dbo.v_questions_programme q WHERE q.entite = b.entite AND q.arrete = b.arrete AND q.cycle = b.cycle AND q.etat_ligne = 'REPONDUE') AS questions_repondues,
       (SELECT COUNT(*) FROM dbo.v_feuilles_du_cycle f WHERE f.vehicule = b.entite AND f.arrete = b.arrete AND f.cycle = b.cycle) AS feuilles,
       (SELECT COUNT(*) FROM dbo.v_feuilles_du_cycle f WHERE f.vehicule = b.entite AND f.arrete = b.arrete AND f.cycle = b.cycle AND f.conclue_le IS NULL) AS feuilles_ouvertes,
       (SELECT COUNT(*) FROM dbo.v_feuilles_du_cycle f WHERE f.vehicule = b.entite AND f.arrete = b.arrete AND f.cycle = b.cycle AND f.conclue_apres_cycle = 1) AS feuilles_conclues_apres,
       (SELECT COUNT(*) FROM dbo.v_lots_perimetre l WHERE l.vehicule = b.entite AND l.arrete = b.arrete AND l.cycle = b.cycle AND l.statut = 'PROPOSE') AS lots_en_attente,
       cc.conclusion, cc.conclu_par, cc.conclu_le, cc.synthese_feuilles AS synthese_enregistree,
       dbo.fn_synthese_feuilles(b.entite, b.arrete, b.cycle) AS synthese_courante,
       d.decision AS derniere_decision, d.decide_par, d.decide_le,
       CASE WHEN d.decision = 'RENVOYE' THEN d.motif END AS motif_renvoi,
       et.etat,
       CAST(CASE et.etat WHEN 'A_CONCLURE' THEN N'À conclure' WHEN 'CONCLU' THEN N'Conclu' WHEN 'VISE' THEN N'Visé' ELSE N'Renvoyé' END AS NVARCHAR (20)) AS etat_libelle,
       CAST(SUBSTRING(o.obstacle, 7, 2000) AS NVARCHAR (2000)) AS blocage_visa,
       ISNULL(s.a_viser, 0) AS a_viser, ISNULL(s.vises, 0) AS vises, ISNULL(s.renvoyes, 0) AS renvoyes, ISNULL(s.decisions, 0) AS decisions,
       CAST(CASE WHEN ISNULL(s.renvoyes, 0) > 0 THEN 'RENVOIS EN COURS' WHEN ISNULL(s.a_viser, 0) > 0 THEN 'EN ATTENTE'
                 WHEN ISNULL(s.decisions, 0) = 0 THEN 'OUVERT' ELSE 'A JOUR' END AS VARCHAR (20)) AS etat_supervision
FROM base b
CROSS APPLY (SELECT dbo.fn_etat_cycle(b.entite, b.arrete, b.cycle) AS etat) et
CROSS APPLY (SELECT dbo.fn_obstacle_visa_cycle(b.entite, b.arrete, b.cycle) AS obstacle) o
LEFT JOIN dbo.conclusion_cycle cc ON cc.entite = b.entite AND cc.arrete = b.arrete AND cc.cycle = b.cycle
OUTER APPLY (SELECT TOP (1) v.decision, v.decide_par, v.decide_le, v.motif FROM dbo.visa v
             WHERE v.nature = 'CYCLE' AND v.objet_ref = b.entite + '|' + b.arrete + '|' + b.cycle ORDER BY v.decide_le DESC, v.id DESC) d
LEFT JOIN sup s ON s.vehicule = b.entite AND s.arrete = b.arrete AND s.cycle = b.cycle;

GO

