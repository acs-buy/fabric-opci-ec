
CREATE   VIEW dbo.v_revision_indicateurs AS
SELECT a.entite, a.arrete,
       p.type_programme,
       (SELECT COUNT(*) FROM dbo.v_questions_programme v WHERE v.entite = a.entite AND v.arrete = a.arrete) AS questions,
       (SELECT COUNT(*) FROM dbo.v_questions_programme v WHERE v.entite = a.entite AND v.arrete = a.arrete AND v.etat_ligne = 'REPONDUE') AS questions_repondues,
       (SELECT COUNT(*) FROM dbo.feuille_travail f WHERE f.entite = a.entite AND f.arrete = a.arrete AND f.cycle IS NOT NULL AND f.cote NOT LIKE 'Q-%') AS feuilles,
       (SELECT COUNT(*) FROM dbo.feuille_travail f WHERE f.entite = a.entite AND f.arrete = a.arrete AND f.cycle IS NOT NULL AND f.cote NOT LIKE 'Q-%' AND f.conclue_le IS NOT NULL) AS feuilles_conclues,
       (SELECT COUNT(*) FROM dbo.ecriture_brouillon b WHERE b.entite = a.entite AND b.arrete = a.arrete) AS od_brouillon,
       (SELECT COUNT(*) FROM dbo.v_couverture_balance c WHERE c.entite = a.entite AND c.arrete = a.arrete) AS comptes,
       (SELECT COUNT(*) FROM dbo.v_couverture_balance c WHERE c.entite = a.entite AND c.arrete = a.arrete AND c.etat = 'COUVERT') AS comptes_couverts,
       (SELECT COUNT(DISTINCT v.cycle) FROM dbo.v_questions_programme v WHERE v.entite = a.entite AND v.arrete = a.arrete) AS cycles,
       (SELECT COUNT(*) FROM dbo.conclusion_cycle c WHERE c.entite = a.entite AND c.arrete = a.arrete) AS cycles_conclus,
       (SELECT COUNT(*) FROM dbo.visa v WHERE v.entite = a.entite AND v.arrete = a.arrete AND v.nature = 'CYCLE' AND v.decision = 'VISE') AS cycles_vises,
       CAST(CASE WHEN EXISTS (SELECT 1 FROM dbo.visa v WHERE v.entite = a.entite AND v.arrete = a.arrete AND v.nature = 'REVUE' AND v.decision = 'VISE') THEN 1 ELSE 0 END AS BIT) AS revue_visee,
       dbo.fn_dossier_verrouille(a.entite, a.arrete) AS verrouille,
       (SELECT verrouille_par FROM dbo.dossier_verrou d WHERE d.entite = a.entite AND d.arrete = a.arrete) AS verrouille_par
FROM dbo.arrete_mission a
LEFT JOIN dbo.programme_travail p ON p.entite = a.entite AND p.arrete = a.arrete;

GO

