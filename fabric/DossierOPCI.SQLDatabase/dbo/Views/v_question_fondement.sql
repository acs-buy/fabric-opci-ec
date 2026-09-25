

-- --- 7 : la lecture, une diligence et son fondement -----------------
CREATE   VIEW dbo.v_question_fondement AS
SELECT q.id AS question_id, q.reference, q.cycle, q.phase, q.section,
       q.enonce, q.type_reponse, q.options,
       CAST(q.obligatoire AS BIT) AS obligatoire, q.doc_attendu,
       q.reference_texte, q.applicabilite, q.statut, q.ordre,
       -- Le fondement vient de dbo.ref_reference pour un paragraphe de
       -- norme professionnelle, de dbo.ref_question_article pour un
       -- article du reglement ANC. La colonne source_fondement dit lequel
       -- des 2 chemins a servi, et le 3e cas, TEXTE_SEUL, designe une
       -- reference que le referentiel des normes ne porte pas encore.
       COALESCE(r.citation_courte,
                CASE WHEN a.article IS NOT NULL
                     THEN N'Reglement ANC 2021-09, art. ' + a.article END,
                q.reference_texte)                    AS fondement,
       r.citation,
       CASE WHEN r.id IS NOT NULL           THEN 'REF_REFERENCE'
            WHEN a.article IS NOT NULL      THEN 'REF_QUESTION_ARTICLE'
            WHEN q.reference_texte IS NOT NULL THEN 'TEXTE_SEUL'
            ELSE NULL END                             AS source_fondement
FROM dbo.ref_question q
LEFT JOIN dbo.ref_question_reference qr
       ON qr.question_reference = q.reference
LEFT JOIN dbo.v_reference r ON r.id = qr.reference_id
LEFT JOIN dbo.ref_question_article a ON a.question_id = q.id;

GO

