-- Objet n° 26 de l'ecran 5 (lot 1) : une ligne par article qu'un referentiel cite par une cle (article_cite de
-- ref_ratio, ref_ratio_memoire et ref_obligation_distribution, ref_ratio_memoire_article, ref_question_article,
-- article de ref_tableau_annexe et de ref_ligne_annexe) ; lignes : les designations des lignes qui le citent
-- (colonne ligne de v_ecran_referentiel_lignes, jamais leur code), suivies entre parentheses du role de la colonne
-- d'ou vient la citation, celui que la page dessine : article_calcul « calcul », dates_respect « dates de respect », dates_respect_professionnel « dates de respect, OPCI professionnel », fondement_grand_public « fondement, OPCI grand public », fondement_professionnel « fondement » ;
-- rien pour l'article principal ; jointes par « ; », une citation identique une fois ; un intitule absent se montre
-- « a remplir » et ne se saisit pas ; un texte europeen se montre tel quel, intitule « hors du CMF ».
-- Pose par 63_SQL/322_e5_vues_choix_inventaire_seuils_articles.sql, genere par 61_DEPLOIEMENT/generer_e5_322_vues_choix_inventaire_seuils_articles.py ;
-- ne pas modifier a la main : regenerer le script quand une table s'inscrit ou qu'une colonne change.
CREATE   VIEW dbo.v_ecran_articles_du_referentiel AS
WITH cit AS (
    SELECT CAST('ref_ratio' AS VARCHAR (120)) AS referentiel, CAST(x.article_cite AS NVARCHAR (120)) AS article,
           CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle, CAST(N'' AS NVARCHAR (60)) AS role,
           0 AS tri, CAST(x.code AS NVARCHAR (400)) AS tri_texte, 1 AS par_cle
    FROM dbo.ref_ratio x WHERE x.article_cite IS NOT NULL
    UNION ALL
    SELECT 'ref_obligation_distribution', x.article_cite, CAST(CAST(x.categorie AS NVARCHAR (200)) AS NVARCHAR (400)), N'', 0, x.categorie, 1
    FROM dbo.ref_obligation_distribution x WHERE x.article_cite IS NOT NULL
    UNION ALL
    -- l'article principal, ou le texte europeen tel quel quand la limite n'a pas d'article du CMF
    SELECT 'ref_ratio_memoire', COALESCE(CAST(x.article_cite AS NVARCHAR (120)), x.article), CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)), N'',
           x.ordre * 10, x.code, CASE WHEN x.article_cite IS NULL THEN 0 ELSE 1 END
    FROM dbo.ref_ratio_memoire x
    UNION ALL
    SELECT 'ref_ratio_memoire', l.article, CAST(CAST(m.code AS NVARCHAR (200)) AS NVARCHAR (400)),
           CASE l.colonne WHEN 'article_calcul' THEN N'calcul' WHEN 'dates_respect' THEN N'dates de respect' WHEN 'dates_respect_professionnel' THEN N'dates de respect, OPCI professionnel' WHEN 'fondement_grand_public' THEN N'fondement, OPCI grand public' WHEN 'fondement_professionnel' THEN N'fondement' ELSE CAST(l.colonne AS NVARCHAR (60)) END,
           m.ordre * 10 + CASE l.colonne WHEN 'article_calcul' THEN 1 WHEN 'dates_respect' THEN 2 WHEN 'dates_respect_professionnel' THEN 3 WHEN 'fondement_grand_public' THEN 4 WHEN 'fondement_professionnel' THEN 5 ELSE 9 END, m.code, 1
    FROM dbo.ref_ratio_memoire_article l JOIN dbo.ref_ratio_memoire m ON m.code = l.code
    UNION ALL
    SELECT 'ref_question_article', x.article, CAST(CONCAT(CAST(x.question_id AS NVARCHAR (200)), N' · ', CAST(x.article AS NVARCHAR (200))) AS NVARCHAR (400)), N'', x.question_id, x.article, 1
    FROM dbo.ref_question_article x
    UNION ALL
    SELECT 'ref_tableau_annexe', x.article, CAST(CAST(x.article AS NVARCHAR (200)) AS NVARCHAR (400)), N'', x.ordre, x.article, 1
    FROM dbo.ref_tableau_annexe x
    UNION ALL
    SELECT 'ref_ligne_annexe', x.article, CAST(CONCAT(CAST(x.article AS NVARCHAR (200)), N' · ', CAST(x.code AS NVARCHAR (200))) AS NVARCHAR (400)), N'', x.ordre, x.code, 1
    FROM dbo.ref_ligne_annexe x
),
des AS (
    SELECT c.referentiel, c.article, c.par_cle,
           ISNULL(l.ligne, c.cle) + CASE WHEN c.role = N'' THEN N'' ELSE N' (' + c.role + N')' END AS citation,
           MIN(c.tri) AS tri, MIN(c.tri_texte) AS tri_texte
    FROM cit c
    LEFT JOIN dbo.v_ecran_referentiel_lignes l ON l.referentiel = c.referentiel AND l.cle = c.cle
    GROUP BY c.referentiel, c.article, c.par_cle,
             ISNULL(l.ligne, c.cle) + CASE WHEN c.role = N'' THEN N'' ELSE N' (' + c.role + N')' END
)
SELECT d.referentiel, d.article,
       CAST(CASE WHEN d.par_cle = 0 THEN N'hors du CMF'
                 ELSE ISNULL(NULLIF(LTRIM(RTRIM(a.intitule)), N''), N'à remplir') END AS NVARCHAR (200)) AS intitule,
       a.source,
       CAST(STRING_AGG(CAST(d.citation AS NVARCHAR (MAX)), N' ; ') WITHIN GROUP (ORDER BY d.tri, d.tri_texte, d.citation)
            AS NVARCHAR (MAX)) AS lignes,
       a.dans_perimetre
FROM des d
LEFT JOIN dbo.ref_article a ON d.par_cle = 1 AND a.article = d.article
GROUP BY d.referentiel, d.article, d.par_cle, a.intitule, a.source, a.dans_perimetre;

GO

