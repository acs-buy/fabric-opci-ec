
-- 3. la grille du questionnaire --------------------------------------------------------------------------
CREATE   VIEW dbo.v_questions_acceptation AS
SELECT f.entite, f.cote, f.phase, f.arrete,
       fq.id AS feuille_question_id, q.id AS question_id, q.reference, q.enonce, q.type_reponse,
       CAST(q.obligatoire AS BIT) AS obligatoire, q.ordre, q.section, q.options, q.doc_attendu,
       fq.reponse, fq.reponse_valeur, COALESCE(fq.reponse, fq.reponse_valeur) AS reponse_lue,
       fq.motif_non_applicable, fq.commentaire, fq.repondu_par, fq.repondu_le,
       CASE WHEN fq.reponse IS NULL AND fq.reponse_valeur IS NULL THEN 'SANS_REPONSE'
            WHEN fq.reponse = 'NON_APPLICABLE' AND fq.motif_non_applicable IS NULL THEN 'MOTIF_MANQUANT'
            ELSE 'REPONDUE' END AS etat_ligne,
       (SELECT COUNT(*) FROM dbo.piece_rattachement pr
         WHERE pr.question_id = q.id AND pr.entite = f.entite) AS pieces,
       f.cote + '|' + q.reference AS cle_ligne
FROM dbo.feuille_question fq
JOIN dbo.feuille_travail f ON f.cote = fq.cote AND f.phase IN ('ACCEPT', 'MAINTIEN')
JOIN dbo.ref_question q ON q.id = fq.question_id;

GO

