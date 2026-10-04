

-- Le montant de chaque ligne des etats, par vehicule et arrete de mission, en N et en N-1. Meme resultat
-- que la version de 239, ligne pour ligne (0 ecart dans les 2 sens sur les 672 lignes, 03/10/2026), ecrit en jointures
-- et agregats sur le detail materialise.
CREATE   VIEW dbo.v_ligne_etat_montant AS
WITH valeur AS (
    -- la valeur d'une ligne DETAIL en N et en N-1, NULL quand la donnee manque
    SELECT l.etat, l.code, a.entite, a.arrete,
           CASE WHEN a.porte_balance = 1 THEN ISNULL(dn.montant, 0) END AS n,
           CASE WHEN a.premier_exercice = 0 AND a.porte_balance_n_1 = 1 THEN ISNULL(dp.montant, 0)
                WHEN a.premier_exercice = 1 THEN sa.montant END AS n_1
    FROM dbo.ref_ligne_etat l
    CROSS JOIN dbo.v_arrete_etat a
    LEFT JOIN dbo.fn_ligne_etat_detail() dn ON dn.etat = l.etat AND dn.code = l.code AND dn.entite = a.entite AND dn.arrete = a.arrete
    LEFT JOIN dbo.fn_ligne_etat_detail() dp ON dp.etat = l.etat AND dp.code = l.code AND dp.entite = a.entite AND dp.arrete = a.arrete_n_1
    LEFT JOIN dbo.saisie_annexe sa ON sa.entite = a.entite AND sa.arrete = a.arrete AND sa.ligne = l.code AND sa.colonne = N'2'
         AND sa.article = CASE l.etat WHEN 'BILAN_ACTIF' THEN '321-2' WHEN 'BILAN_PASSIF' THEN '321-6' ELSE '322-2' END
    WHERE l.type_ligne = 'DETAIL'
),
total AS (
    -- une ligne TOTAL ou RESULTAT : la somme signee de ses lignes DETAIL, NULL des que l'une manque
    SELECT f.etat, f.code, w.entite, w.arrete,
           CASE WHEN COUNT(*) = COUNT(w.n) THEN SUM(f.signe * w.n) END AS n,
           CASE WHEN COUNT(*) = COUNT(w.n_1) THEN SUM(f.signe * w.n_1) END AS n_1
    FROM dbo.v_ligne_etat_formule f
    JOIN valeur w ON w.etat = f.etat AND w.code = f.code_detail
    WHERE NOT EXISTS (SELECT 1 FROM dbo.v_controle_formule_ligne_etat c WHERE c.etat = f.etat AND c.code = f.code)
    GROUP BY f.etat, f.code, w.entite, w.arrete
),
capitaux AS (
    -- P_CP, art. 321-1 : la somme de P_CP_1 a P_CP_5
    SELECT w.etat, CAST('P_CP' AS VARCHAR (20)) AS code, w.entite, w.arrete,
           CASE WHEN COUNT(*) = COUNT(w.n) THEN SUM(w.n) END AS n,
           CASE WHEN COUNT(*) = COUNT(w.n_1) THEN SUM(w.n_1) END AS n_1
    FROM valeur w WHERE w.etat = 'BILAN_PASSIF' AND w.code LIKE 'P[_]CP[_]%'
    GROUP BY w.etat, w.entite, w.arrete
),
calcul AS (
    SELECT etat, code, entite, arrete, n, n_1 FROM valeur
    UNION ALL SELECT etat, code, entite, arrete, n, n_1 FROM total
    UNION ALL SELECT etat, code, entite, arrete, n, n_1 FROM capitaux
)
SELECT l.etat, l.code, l.libelle, l.type_ligne, l.romain, l.ordre,
       l.article, l.renvoi,
       a.entite, a.arrete,
       CAST(c.n AS DECIMAL (19, 2)) AS exercice_n,
       CAST(c.n_1 AS DECIMAL (19, 2)) AS exercice_n_1,
       -- « Le cas echeant les lignes a 0 peuvent etre supprimees », article 321-2 : la regle est permissive.
       CAST(CASE WHEN l.type_ligne = 'DETAIL' AND c.n = 0 AND ISNULL(c.n_1, 0) = 0 THEN 1 ELSE 0 END AS BIT) AS supprimable,
       l.racines, l.formule,
       -- REGLE 0.4 : la ou la base n'a pas la donnee, NULL et « à remplir », jamais 0,00.
       CAST(CASE WHEN c.n IS NULL AND (l.type_ligne <> 'RUBRIQUE' OR l.code = 'P_CP') THEN N'à remplir' END AS NVARCHAR (20)) AS exercice_n_libelle,
       CAST(CASE WHEN c.n_1 IS NULL AND (l.type_ligne <> 'RUBRIQUE' OR l.code = 'P_CP') THEN N'à remplir' END AS NVARCHAR (20)) AS exercice_n_1_libelle
FROM dbo.ref_ligne_etat l
CROSS JOIN dbo.v_arrete_etat a
LEFT JOIN calcul c ON c.etat = l.etat AND c.code = l.code AND c.entite = a.entite AND c.arrete = a.arrete;

GO

