
-- ------------------------------------------------------------------ n° 17 : les visas de la valorisation
-- Les visas EVALUATION, DEROGATION, SYNTHESE, PUBLICATION et ceux des lots DERIVABLE, du vehicule et de ses filiales.
-- decide_le a sa precision d'origine : cle de tri de la table.
CREATE   VIEW dbo.v_ecran_visas_valorisation AS
SELECT pv.vehicule, v.arrete, v.entite, v.id AS visa_id, v.nature,
       CAST(CASE v.nature WHEN 'EVALUATION' THEN N'Valeur retenue' WHEN 'DEROGATION' THEN N'Dérogation' WHEN 'LOT' THEN N'Lot'
                          WHEN 'SYNTHESE' THEN N'Synthèse' WHEN 'PUBLICATION' THEN N'Publication de la VL' END AS NVARCHAR (30)) AS nature_libelle,
       CAST(CASE v.nature WHEN 'EVALUATION' THEN ISNULL(ev.code_actif, N'valeur n° ' + v.objet_ref)
                          WHEN 'DEROGATION' THEN ISNULL(dg.cote, N'dérogation n° ' + v.objet_ref)
                          WHEN 'LOT' THEN N'lot n° ' + v.objet_ref + N' · ' + l.entite
                          ELSE N'arrêté du ' + dbo.fn_date_ecran(v.arrete) END AS NVARCHAR (200)) AS objet_libelle,
       v.objet_ref, v.decision,
       CAST(CASE v.decision WHEN 'VISE' THEN N'visé' WHEN 'RENVOYE' THEN N'renvoyé' END AS NVARCHAR (10)) AS decision_libelle,
       v.motif, v.propose_par, v.decide_par,
       dbo.fn_nom_personne_ecran(v.entite, v.decide_par) AS vise_par,
       v.decide_le,
       pv.vehicule + '|' + CAST(v.id AS VARCHAR (12)) AS cle_ecran
FROM dbo.visa v
JOIN dbo.v_perimetre_vehicule pv ON pv.entite = v.entite AND pv.arrete = v.arrete
LEFT JOIN dbo.evaluation_actif ev ON v.nature = 'EVALUATION' AND ev.id = TRY_CAST(v.objet_ref AS INT)
LEFT JOIN dbo.derogation dg ON v.nature = 'DEROGATION' AND dg.id = TRY_CAST(v.objet_ref AS INT)
LEFT JOIN dbo.lot_ecritures l ON v.nature = 'LOT' AND l.id = TRY_CAST(v.objet_ref AS INT)
WHERE v.nature IN ('EVALUATION', 'DEROGATION', 'SYNTHESE', 'PUBLICATION')
   OR (v.nature = 'LOT' AND l.famille = 'DERIVABLE');

GO

