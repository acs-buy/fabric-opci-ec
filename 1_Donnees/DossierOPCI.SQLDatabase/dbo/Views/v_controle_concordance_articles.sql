-- C13 : un article de dbo.ref_article absent de dbo.ref_reference, ou
-- l'inverse. Les 2 tables doivent concorder. ATTENDU zero.
CREATE   VIEW dbo.v_controle_concordance_articles AS
SELECT a.article, a.source, 'absent de ref_reference' AS ecart
FROM dbo.ref_article a
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.ref_reference r
    WHERE r.reference = a.article
      AND r.norme = CASE WHEN a.source = 'CMF' THEN 'CMF' ELSE 'ANC2021-09' END)
UNION ALL
SELECT r.reference, r.norme, 'absent de ref_article'
FROM dbo.ref_reference r
WHERE r.norme IN ('ANC2021-09', 'CMF')
  AND NOT EXISTS (SELECT 1 FROM dbo.ref_article a WHERE a.article = r.reference);

GO

