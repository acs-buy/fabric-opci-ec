
-- C41 : une diligence dont la reference textuelle cite une source que le
-- referentiel des normes ne porte pas, un paragraphe du referentiel
-- normatif CNOEC ou un article du reglement general de l'AMF. Elle n'est
-- pas fausse, mais sa citation ne se met pas a jour quand le referentiel
-- change. La vue les liste pour que le referentiel soit complete. Elle
-- n'est PAS attendue a zero en l'etat.
CREATE   VIEW dbo.v_question_reference_non_appariee AS
SELECT q.reference, q.phase, q.section, q.reference_texte
FROM dbo.ref_question q
WHERE q.phase IN ('ACCEPT', 'MAINTIEN')
  AND q.reference_texte IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.ref_question_reference qr
                  WHERE qr.question_reference = q.reference);

GO

