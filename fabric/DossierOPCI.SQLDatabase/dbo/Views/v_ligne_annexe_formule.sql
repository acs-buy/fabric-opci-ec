
CREATE   VIEW dbo.v_ligne_annexe_formule AS
WITH est_expr AS (
    SELECT article, code,
           LTRIM(RTRIM(LEFT(formule_calcul, CHARINDEX(N' ;', formule_calcul + N' ;') - 1))) AS formule_calcul
    FROM dbo.ref_ligne_annexe
    WHERE formule_calcul IS NOT NULL AND formule_calcul NOT LIKE '%:%' AND formule_calcul <> 'N1'
),
terme AS (
    SELECT x.article, x.code, LTRIM(RTRIM(REPLACE(s.value, N'-', N''))) AS terme,
           CASE WHEN LTRIM(s.value) LIKE N'-%' THEN -1 ELSE 1 END AS signe
    FROM est_expr x CROSS APPLY STRING_SPLIT(REPLACE(x.formule_calcul, N' - ', N' + -'), N'+') s
),
dev AS (
    SELECT article, code, terme, signe, 0 AS p FROM terme
    UNION ALL
    SELECT d.article, d.code, t.terme, d.signe * t.signe, d.p + 1
    FROM dev d JOIN terme t ON t.article = d.article AND t.code = d.terme WHERE d.p < 10
)
SELECT d.article, d.code, d.terme AS code_composante, SUM(d.signe) AS signe
FROM dev d
WHERE NOT EXISTS (SELECT 1 FROM est_expr x WHERE x.article = d.article AND x.code = d.terme)
GROUP BY d.article, d.code, d.terme;

GO

