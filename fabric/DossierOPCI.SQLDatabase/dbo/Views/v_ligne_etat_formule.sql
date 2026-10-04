
-- 1. LES FORMULES, DEVELOPPEES JUSQU'AUX LIGNES DETAIL, avec leur signe.
CREATE   VIEW dbo.v_ligne_etat_formule AS
WITH terme AS (
    SELECT l.etat, l.code, LTRIM(RTRIM(REPLACE(s.value, N'-', N''))) AS terme,
           CASE WHEN LTRIM(s.value) LIKE N'-%' THEN -1 ELSE 1 END AS signe
    FROM dbo.ref_ligne_etat l
    CROSS APPLY STRING_SPLIT(REPLACE(l.formule, N' - ', N' + -'), N'+') s
    WHERE l.type_ligne IN ('TOTAL', 'RESULTAT') AND l.formule IS NOT NULL AND l.formule <> N'somme des lignes de detail'
    UNION ALL
    SELECT l.etat, l.code, d.code, 1
    FROM dbo.ref_ligne_etat l JOIN dbo.ref_ligne_etat d ON d.etat = l.etat AND d.type_ligne = 'DETAIL'
    WHERE l.type_ligne IN ('TOTAL', 'RESULTAT') AND l.formule = N'somme des lignes de detail'
),
developpe AS (
    SELECT t.etat, t.code, t.terme, t.signe, 0 AS profondeur FROM terme t
    UNION ALL
    SELECT d.etat, d.code, t.terme, d.signe * t.signe, d.profondeur + 1
    FROM developpe d JOIN terme t ON t.etat = d.etat AND t.code = d.terme
    WHERE d.profondeur < 10
)
SELECT d.etat, d.code, d.terme AS code_detail, SUM(d.signe) AS signe
FROM developpe d
JOIN dbo.ref_ligne_etat x ON x.etat = d.etat AND x.code = d.terme AND x.type_ligne = 'DETAIL'
GROUP BY d.etat, d.code, d.terme;

GO

