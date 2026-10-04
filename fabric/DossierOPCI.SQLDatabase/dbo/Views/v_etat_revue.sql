

-- UNE LIGNE PAR VEHICULE ET ARRETE DE MISSION. Le dernier deverrouillage se lit sur le journal des visas :
-- une ligne REVUE RENVOYE dont la decision REVUE qui la precede sur la meme reference est VISE.
CREATE   VIEW dbo.v_etat_revue AS
WITH revue AS (
    SELECT v.id, v.objet_ref, v.decision, v.motif, v.propose_par, v.decide_par, v.decide_le,
           LAG(v.decision) OVER (PARTITION BY v.objet_ref ORDER BY v.decide_le, v.id) AS precedente
    FROM dbo.visa v WHERE v.nature = 'REVUE'
)
SELECT a.entite, a.arrete,
       cr.conclusion, cr.conclu_par, cr.conclu_le,
       (SELECT COUNT(*) FROM dbo.ref_cycle c WHERE dbo.fn_cycle_au_programme(a.entite, a.arrete, c.code) = 1) AS cycles,
       (SELECT COUNT(*) FROM dbo.conclusion_cycle c WHERE c.entite = a.entite AND c.arrete = a.arrete
         AND dbo.fn_cycle_au_programme(a.entite, a.arrete, c.cycle) = 1) AS cycles_conclus,
       (SELECT COUNT(*) FROM dbo.ref_cycle c WHERE dbo.fn_cycle_au_programme(a.entite, a.arrete, c.code) = 1
         AND dbo.fn_etat_cycle(a.entite, a.arrete, c.code) = 'VISE') AS cycles_vises,
       (SELECT COUNT(*) FROM dbo.v_lots_perimetre l WHERE l.vehicule = a.entite AND l.arrete = a.arrete AND l.statut = 'PROPOSE') AS lots_en_attente,
       (SELECT COUNT(*) FROM dbo.v_perimetre_vehicule p WHERE p.vehicule = a.entite AND p.arrete = a.arrete) AS perimetre_entites,
       (SELECT STRING_AGG(CAST(p.entite AS NVARCHAR (MAX)), N', ') WITHIN GROUP (ORDER BY CASE WHEN p.entite = p.vehicule THEN 0 ELSE 1 END, p.entite)
        FROM dbo.v_perimetre_vehicule p WHERE p.vehicule = a.entite AND p.arrete = a.arrete) AS perimetre,
       d.decision AS derniere_decision, d.decide_par, d.decide_le,
       CASE WHEN d.decision = 'RENVOYE' THEN d.motif END AS motif_renvoi,
       CAST(ISNULL(dv.verrouille, 0) AS BIT) AS verrouille, dv.verrouille_par, dv.verrouille_le,
       dd.propose_par AS dernier_deverrouillage_demande_par, dd.decide_par AS dernier_deverrouillage_par,
       dd.decide_le AS dernier_deverrouillage_le, dd.motif AS dernier_deverrouillage_motif,
       et.etat,
       CAST(CASE et.etat WHEN 'A_CONCLURE' THEN N'À conclure' WHEN 'CONCLUE' THEN N'Conclue' WHEN 'VISEE' THEN N'Visée' ELSE N'Renvoyée' END AS NVARCHAR (20)) AS etat_libelle,
       CAST(SUBSTRING(dbo.fn_obstacle_visa_revue(a.entite, a.arrete), 7, 2000) AS NVARCHAR (2000)) AS blocage_visa,
       a.entite + '|' + a.arrete AS cle_arrete
FROM dbo.arrete_mission a
JOIN dbo.ref_entite e ON e.code = a.entite AND e.forme_vehicule IS NOT NULL
CROSS APPLY (SELECT dbo.fn_etat_revue(a.entite, a.arrete) AS etat) et
LEFT JOIN dbo.conclusion_revue cr ON cr.entite = a.entite AND cr.arrete = a.arrete
LEFT JOIN dbo.dossier_verrou dv ON dv.entite = a.entite AND dv.arrete = a.arrete
OUTER APPLY (SELECT TOP (1) v.decision, v.decide_par, v.decide_le, v.motif FROM dbo.visa v
             WHERE v.nature = 'REVUE' AND v.objet_ref = a.entite + '|' + a.arrete ORDER BY v.decide_le DESC, v.id DESC) d
OUTER APPLY (SELECT TOP (1) r.propose_par, r.decide_par, r.decide_le, r.motif FROM revue r
             WHERE r.objet_ref = a.entite + '|' + a.arrete AND r.decision = 'RENVOYE' AND r.precedente = 'VISE'
             ORDER BY r.decide_le DESC, r.id DESC) dd;

GO

