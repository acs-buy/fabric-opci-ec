

-- --- 4 : V5, les questions du cycle par dossier ----------------------
-- dbo.feuille_question ne porte pas le cycle : il est sur la feuille. La
-- relation « cycle vers questions » de l'ecran A0 a besoin d'une cle
-- simple et d'une colonne d'affichage concatenee pour son en-tete.
CREATE   VIEW dbo.v_questions_du_cycle AS
SELECT fq.id                              AS feuille_question_id,
       f.cote, f.entite, f.arrete, f.cycle, f.phase,
       q.id                               AS question_id,
       q.reference,
       q.enonce,
       q.type_reponse,
       CAST(q.obligatoire AS BIT)         AS obligatoire,
       q.ordre,
       fq.reponse,
       fq.reponse_valeur,
       COALESCE(fq.reponse, fq.reponse_valeur) AS reponse_lue,
       fq.motif_non_applicable,
       fq.commentaire,
       fq.repondu_par, fq.repondu_le,
       -- La colonne d'affichage, pour l'en-tete du tableau lie.
       q.reference + N' ' + LEFT(q.enonce, 90)          AS affichage,
       f.cycle + N' ' + f.entite + N' au ' + f.arrete   AS affichage_cycle,
       -- L'etat de la ligne, pour le formatage conditionnel.
       CASE WHEN fq.reponse IS NULL AND fq.reponse_valeur IS NULL
                                                 THEN 'SANS_REPONSE'
            WHEN fq.reponse = 'NON_APPLICABLE'
                 AND fq.motif_non_applicable IS NULL THEN 'MOTIF_MANQUANT'
            ELSE 'REPONDUE' END                          AS etat_ligne,
       (SELECT COUNT(*) FROM dbo.piece_rattachement pr
        WHERE pr.question_id = q.id AND pr.entite = f.entite
          AND (pr.arrete IS NULL OR pr.arrete = f.arrete)) AS pieces
FROM dbo.feuille_question fq
JOIN dbo.feuille_travail f ON f.cote = fq.cote
JOIN dbo.ref_question q ON q.id = fq.question_id;

GO

