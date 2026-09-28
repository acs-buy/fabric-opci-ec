
-- UNE LIGNE PAR QUESTION ELIGIBLE DE CHAQUE PROGRAMME, active ou non. Eligible : question de cycle, non
-- ecartee, applicable au type de l'arrete. Une question retiree y reste, actif = 0 : l'ecran la reprend.
CREATE   VIEW dbo.v_programme_selection AS
SELECT p.entite, p.arrete, p.id AS programme_id, p.type_programme, q.cycle, q.reference, q.enonce, q.niveau_programme, q.ordre,
       CAST(ISNULL(pq.actif, 0) AS BIT) AS actif,
       pq.origine,
       CAST(CASE WHEN EXISTS (SELECT 1 FROM dbo.feuille_question fq
                              WHERE fq.cote = 'Q-' + q.cycle + '-P' + CAST(p.id AS VARCHAR (10)) AND fq.question_id = q.id
                                AND (fq.reponse IS NOT NULL OR fq.reponse_valeur IS NOT NULL)) THEN 1 ELSE 0 END AS BIT) AS repondue,
       pq.modifie_par, pq.modifie_le,
       p.entite + '|' + p.arrete + '|' + q.reference AS cle_ecran
FROM dbo.programme_travail p
CROSS APPLY (SELECT TOP 1 am.type_arrete FROM dbo.arrete_mission am WHERE am.entite = p.entite AND am.arrete = p.arrete) a
JOIN dbo.ref_question q ON q.cycle IS NOT NULL AND q.statut <> 'ECARTEE'
     AND (q.applicabilite = 'LES_DEUX' OR (q.applicabilite = 'ARRETE_CLOTURE' AND a.type_arrete = 'ANNUEL')
          OR (q.applicabilite = 'ARRETE_VL' AND a.type_arrete <> 'ANNUEL'))
LEFT JOIN dbo.programme_question pq ON pq.programme_id = p.id AND pq.question_id = q.id;

GO

