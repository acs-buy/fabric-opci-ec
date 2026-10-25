-- 2 colonnes d'un meme referentiel du cabinet sous le meme libelle effectif (libelle de la vue, a defaut celui de
-- '*'). ATTENDU zero : une matrice regroupe ses colonnes par libelle.
CREATE   VIEW dbo.v_controle_libelle_colonne_double AS
WITH effectif AS (
    SELECT r.table_nom AS referentiel, c.name COLLATE DATABASE_DEFAULT AS colonne,
           COALESCE(p.libelle, g.libelle) AS libelle
    FROM dbo.ref_referentiel r
    JOIN sys.columns c ON c.object_id = OBJECT_ID('dbo.' + r.table_nom)
    LEFT JOIN dbo.ref_libelle_colonne p ON p.vue = r.table_nom AND p.colonne = c.name COLLATE DATABASE_DEFAULT
    LEFT JOIN dbo.ref_libelle_colonne g ON g.vue = '*' AND g.colonne = c.name COLLATE DATABASE_DEFAULT
    WHERE r.du_cabinet = 1
)
SELECT referentiel, libelle, COUNT(*) AS colonnes,
       STRING_AGG(CAST(colonne AS NVARCHAR (MAX)), N', ') WITHIN GROUP (ORDER BY colonne) AS noms
FROM effectif
WHERE libelle IS NOT NULL
GROUP BY referentiel, libelle
HAVING COUNT(*) > 1;

GO

