
-- --- 4. les vues du rapport ---------------------------------------------------------------------------
CREATE   VIEW dbo.v_questions_programme AS
SELECT f.entite, f.arrete, f.cycle, p.id AS programme_id, p.type_programme, fq.cote, fq.id AS feuille_question_id,
       q.id AS question_id, q.reference, q.enonce, q.type_reponse, CAST(q.obligatoire AS BIT) AS obligatoire, q.ordre, q.section,
       fq.reponse, fq.reponse_valeur, COALESCE(fq.reponse, fq.reponse_valeur) AS reponse_lue,
       fq.motif_non_applicable, fq.commentaire, fq.repondu_par, fq.repondu_le,
       CASE WHEN fq.reponse IS NULL AND fq.reponse_valeur IS NULL THEN 'SANS_REPONSE'
            WHEN fq.reponse = 'NON_APPLICABLE' AND fq.motif_non_applicable IS NULL THEN 'MOTIF_MANQUANT'
            ELSE 'REPONDUE' END AS etat_ligne,
       ft.cote AS feuille_cote, ft.modele_code AS feuille_modele, ft.forme_conclusion AS feuille_forme, ft.conclue_le AS feuille_conclue_le,
       (SELECT COUNT(*) FROM dbo.ecriture_brouillon b WHERE b.entite = f.entite AND b.arrete = f.arrete AND b.question_id = q.id) AS od_brouillon,
       (SELECT COUNT(*) FROM dbo.lot_ecritures l WHERE l.entite = f.entite AND l.arrete = f.arrete AND l.question_id = q.id AND l.statut <> 'REJETE') AS od_lots,
       (SELECT COUNT(*) FROM dbo.piece_rattachement pr WHERE pr.question_id = q.id AND pr.entite = f.entite AND (pr.arrete IS NULL OR pr.arrete = f.arrete)) AS pieces,
       f.entite + '|' + f.arrete + '|' + f.cycle AS cle_cycle
FROM dbo.feuille_question fq
JOIN dbo.feuille_travail f ON f.cote = fq.cote AND f.cote LIKE 'Q-%'
JOIN dbo.programme_travail p ON p.entite = f.entite AND p.arrete = f.arrete AND f.cote = 'Q-' + f.cycle + '-P' + CAST(p.id AS VARCHAR (10))
JOIN dbo.ref_question q ON q.id = fq.question_id
OUTER APPLY (SELECT TOP 1 x.cote, x.modele_code, x.forme_conclusion, x.conclue_le FROM dbo.feuille_travail x
             WHERE x.entite = f.entite AND x.arrete = f.arrete AND x.question_id = q.id ORDER BY x.prepare_le DESC) ft;

GO

