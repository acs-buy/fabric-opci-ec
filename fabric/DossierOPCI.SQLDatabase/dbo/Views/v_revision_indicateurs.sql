

-- LES INDICATEURS SUR LA DERNIERE DECISION, et les colonnes du dernier deverrouillage, en
-- dernier. Les autres colonnes ne changent pas.
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
       (SELECT COUNT(*) FROM dbo.conclusion_cycle c WHERE c.entite = a.entite AND c.arrete = a.arrete
         AND dbo.fn_cycle_au_programme(a.entite, a.arrete, c.cycle) = 1) AS cycles_conclus,
       (SELECT COUNT(*) FROM dbo.ref_cycle c WHERE dbo.fn_cycle_au_programme(a.entite, a.arrete, c.code) = 1
         AND dbo.fn_etat_cycle(a.entite, a.arrete, c.code) = 'VISE') AS cycles_vises,
       dbo.fn_revue_visee(a.entite, a.arrete) AS revue_visee,
       dbo.fn_dossier_verrouille(a.entite, a.arrete) AS verrouille,
       (SELECT verrouille_par FROM dbo.dossier_verrou d WHERE d.entite = a.entite AND d.arrete = a.arrete) AS verrouille_par,
       (SELECT deverrouille_par FROM dbo.dossier_verrou d WHERE d.entite = a.entite AND d.arrete = a.arrete) AS deverrouille_par,
       (SELECT deverrouille_le FROM dbo.dossier_verrou d WHERE d.entite = a.entite AND d.arrete = a.arrete) AS deverrouille_le
FROM dbo.arrete_mission a
LEFT JOIN dbo.programme_travail p ON p.entite = a.entite AND p.arrete = a.arrete;

GO

