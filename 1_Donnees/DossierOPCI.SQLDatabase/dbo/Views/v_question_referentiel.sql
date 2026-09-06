
-- La seconde reference du fondement legal en colonne propre, que la
-- revue demande : une question peut citer un article du reglement ET un
-- paragraphe de norme. La premiere est dans ref_question_article, la
-- seconde dans ref_question_reference : la vue les expose separement,
-- l'ecran R2 en faisant 2 colonnes.
CREATE   VIEW dbo.v_question_referentiel AS
SELECT q.id AS question_id, q.reference, q.cycle, q.phase, q.section,
       q.enonce, q.type_reponse, q.options, q.doc_attendu,
       CAST(q.obligatoire AS BIT) AS obligatoire,
       q.applicabilite, q.statut, q.ordre, q.en_vigueur_depuis,
       q.modifie_par, q.modifie_le,
       -- Premier fondement : l'article du reglement ANC ou du code.
       a.articles                          AS fondement_articles,
       -- Second fondement : le paragraphe de norme professionnelle.
       n.paragraphes                       AS fondement_paragraphes,
       q.reference_texte                   AS fondement_texte,
       CAST(CASE WHEN EXISTS (SELECT 1 FROM dbo.modele_ecriture m
                              WHERE m.question_id = q.id)
                 THEN 1 ELSE 0 END AS BIT) AS modele_ecriture,
       m.modele_code                       AS modele_feuille
FROM dbo.ref_question q
OUTER APPLY (
    SELECT STRING_AGG(CAST(x.article AS NVARCHAR (MAX)), N', ') AS articles
    FROM dbo.ref_question_article x WHERE x.question_id = q.id
) AS a
OUTER APPLY (
    SELECT STRING_AGG(CAST(r.norme + N' ' + r.reference AS NVARCHAR (MAX)),
                      N', ') AS paragraphes
    FROM dbo.ref_question_reference qr
    JOIN dbo.ref_reference r ON r.id = qr.reference_id
    WHERE qr.question_reference = q.reference
) AS n
OUTER APPLY (
    SELECT TOP 1 rqm.modele_code FROM dbo.ref_question_modele rqm
    WHERE rqm.question_id = q.id
) AS m;

GO

