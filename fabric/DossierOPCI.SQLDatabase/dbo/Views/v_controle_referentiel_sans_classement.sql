-- Le referentiel du cabinet sans domaine ou sans categorie, la categorie rangee sous 2 domaines, 2 referentiels de
-- meme rang dans une categorie ; et, pour les tris des segments (B9, tris n° 66 et 67), un domaine ou une categorie
-- sous 2 rangs. ATTENDU zero.
CREATE   VIEW dbo.v_controle_referentiel_sans_classement AS
SELECT CAST(N'sans domaine ou sans catégorie' AS NVARCHAR (60)) AS anomalie, r.table_nom,
       CAST(r.libelle AS NVARCHAR (320)) AS detail
FROM dbo.ref_referentiel r
WHERE r.du_cabinet = 1
  AND (r.domaine IS NULL OR r.domaine_ordre IS NULL OR r.categorie IS NULL OR r.categorie_ordre IS NULL
       OR r.rang_categorie IS NULL)
UNION ALL
SELECT N'catégorie sous 2 domaines', r.table_nom, CAST(r.categorie + N' : ' + r.domaine AS NVARCHAR (320))
FROM dbo.ref_referentiel r
WHERE r.du_cabinet = 1
  AND r.categorie IN (SELECT x.categorie FROM dbo.ref_referentiel x WHERE x.du_cabinet = 1 AND x.categorie IS NOT NULL
                      GROUP BY x.categorie HAVING COUNT(DISTINCT x.domaine) > 1)
UNION ALL
SELECT N'rang en double dans la catégorie', r.table_nom,
       CAST(r.categorie + N', rang ' + CAST(r.rang_categorie AS NVARCHAR (10)) AS NVARCHAR (320))
FROM dbo.ref_referentiel r
WHERE r.du_cabinet = 1
  AND EXISTS (SELECT 1 FROM dbo.ref_referentiel x WHERE x.du_cabinet = 1 AND x.categorie = r.categorie
                AND x.rang_categorie = r.rang_categorie AND x.table_nom <> r.table_nom)
UNION ALL
SELECT N'domaine sous 2 rangs', r.table_nom, CAST(r.domaine AS NVARCHAR (320))
FROM dbo.ref_referentiel r
WHERE r.du_cabinet = 1
  AND r.domaine IN (SELECT x.domaine FROM dbo.ref_referentiel x WHERE x.du_cabinet = 1 AND x.domaine IS NOT NULL
                    GROUP BY x.domaine HAVING COUNT(DISTINCT x.domaine_ordre) > 1)
UNION ALL
SELECT N'catégorie sous 2 rangs', r.table_nom, CAST(r.categorie AS NVARCHAR (320))
FROM dbo.ref_referentiel r
WHERE r.du_cabinet = 1
  AND r.categorie IN (SELECT x.categorie FROM dbo.ref_referentiel x WHERE x.du_cabinet = 1 AND x.categorie IS NOT NULL
                      GROUP BY x.categorie HAVING COUNT(DISTINCT x.categorie_ordre) > 1);

GO

