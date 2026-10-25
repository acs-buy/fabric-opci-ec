-- C13 : un article de dbo.ref_article absent de dbo.ref_reference, ou
-- l'inverse. Les 2 tables doivent concorder. ATTENDU zero.
-- C13 modifiee par 63_SQL/320_e5_articles_cites.sql (ecran 5, lot 1,
-- objet n° 25 ; decision D-a de la session base des 19 et 20/10/2026) :
-- la 1re branche ne compte pas un article du CMF que seules les limites citent,
-- en article principal (ref_ratio_memoire.article_cite) ou dans un de
-- leurs textes (ref_ratio_memoire_article), et qu'aucune autre colonne
-- ne cite par cle etrangere (ref_ratio, ref_obligation_distribution,
-- ref_question_article, saisie_annexe) : la regle 3 de la feuille de
-- route de l'ecran 5 interdit de l'inscrire dans ref_reference. La 2e
-- branche est celle d'avant.
CREATE   VIEW dbo.v_controle_concordance_articles AS
SELECT a.article, a.source, 'absent de ref_reference' AS ecart
FROM dbo.ref_article a
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.ref_reference r
    WHERE r.reference = a.article
      AND r.norme = CASE WHEN a.source = 'CMF' THEN 'CMF' ELSE 'ANC2021-09' END)
  AND NOT (a.source = 'CMF'
           AND (EXISTS (SELECT 1 FROM dbo.ref_ratio_memoire m WHERE m.article_cite = a.article)
                OR EXISTS (SELECT 1 FROM dbo.ref_ratio_memoire_article l WHERE l.article = a.article))
           AND NOT EXISTS (SELECT 1 FROM dbo.ref_ratio t WHERE t.article_cite = a.article)
           AND NOT EXISTS (SELECT 1 FROM dbo.ref_obligation_distribution o WHERE o.article_cite = a.article)
           AND NOT EXISTS (SELECT 1 FROM dbo.ref_question_article q WHERE q.article = a.article)
           AND NOT EXISTS (SELECT 1 FROM dbo.saisie_annexe s WHERE s.article = a.article))
UNION ALL
SELECT r.reference, r.norme, 'absent de ref_article'
FROM dbo.ref_reference r
WHERE r.norme IN ('ANC2021-09', 'CMF')
  AND NOT EXISTS (SELECT 1 FROM dbo.ref_article a WHERE a.article = r.reference);

GO

