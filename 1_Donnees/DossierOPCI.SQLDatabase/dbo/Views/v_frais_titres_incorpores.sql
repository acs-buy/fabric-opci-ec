

-- BLOC 2 : dbo.v_frais_titres_incorpores, seule dans son lot
--
-- ATTENDU : 0 ligne
-- MOTIF 1, COUT_ECARTE_DU_PRIX_DE_REVIENT : solde des comptes 252 à 258 par actif different du prix de revient
-- MOTIF 2, SUBDIVISION_DE_FRAIS_SOUS_LES_TITRES : subdivision de la classe 25 dont le libelle designe des frais
-- MOTIF 3, FRAIS_SANS_AXE_ACTIF : ligne au compte 1041 ou 1049 sans axe actif
-- MOTIF 4, COUT_TITRE_SANS_AXE_ACTIF : ligne aux comptes 252 à 258 sans axe actif
CREATE   VIEW dbo.v_frais_titres_incorpores AS
SELECT
    CAST('COUT_ECARTE_DU_PRIX_DE_REVIENT' AS VARCHAR (40)) AS motif,
    CAST(a.code AS VARCHAR (20))                           AS code_actif,
    CAST(NULL AS VARCHAR (20))                             AS compte,
    CAST(l.arrete AS VARCHAR (20))                         AS arrete,
    CAST(SUM(e.debit - e.credit) AS DECIMAL (19,2))        AS montant_constate,
    CAST(MAX(a.prix_de_revient) AS DECIMAL (19,2))         AS montant_attendu,
    CAST(COUNT(*) AS INT)                                  AS lignes
FROM dbo.ecriture e
INNER JOIN dbo.lot_ecritures l ON l.id = e.lot_id
INNER JOIN dbo.ecriture_axe  x ON x.ecriture_id = e.id
INNER JOIN dbo.actif         a ON a.code = x.code_actif
WHERE e.compte_num IN ('252', '254', '256', '258')
  AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
GROUP BY a.code, l.arrete
HAVING SUM(e.debit - e.credit) <> MAX(a.prix_de_revient)

UNION ALL

SELECT
    CAST('SUBDIVISION_DE_FRAIS_SOUS_LES_TITRES' AS VARCHAR (40)) AS motif,
    CAST(NULL AS VARCHAR (20))                                   AS code_actif,
    CAST(c.compte AS VARCHAR (20))                               AS compte,
    CAST(NULL AS VARCHAR (20))                                   AS arrete,
    CAST(NULL AS DECIMAL (19,2))                                 AS montant_constate,
    CAST(NULL AS DECIMAL (19,2))                                 AS montant_attendu,
    CAST(1 AS INT)                                               AS lignes
FROM dbo.ref_compte c
WHERE c.compte LIKE '25%'
  AND c.compte NOT IN ('25', '252', '254', '256', '258')
  AND c.libelle LIKE N'%rais%acquisition%'

UNION ALL

SELECT
    CAST('FRAIS_SANS_AXE_ACTIF' AS VARCHAR (40))           AS motif,
    CAST(NULL AS VARCHAR (20))                             AS code_actif,
    CAST(e.compte_num AS VARCHAR (20))                     AS compte,
    CAST(l.arrete AS VARCHAR (20))                         AS arrete,
    CAST(SUM(e.debit - e.credit) AS DECIMAL (19,2))        AS montant_constate,
    CAST(NULL AS DECIMAL (19,2))                           AS montant_attendu,
    CAST(COUNT(*) AS INT)                                  AS lignes
FROM dbo.ecriture e
INNER JOIN dbo.lot_ecritures l ON l.id = e.lot_id
LEFT JOIN  dbo.ecriture_axe  x ON x.ecriture_id = e.id
WHERE e.compte_num IN ('1041', '1049')
  AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
  AND x.code_actif IS NULL
GROUP BY e.compte_num, l.arrete

UNION ALL

SELECT
    CAST('COUT_TITRE_SANS_AXE_ACTIF' AS VARCHAR (40))      AS motif,
    CAST(NULL AS VARCHAR (20))                             AS code_actif,
    CAST(e.compte_num AS VARCHAR (20))                     AS compte,
    CAST(l.arrete AS VARCHAR (20))                         AS arrete,
    CAST(SUM(e.debit - e.credit) AS DECIMAL (19,2))        AS montant_constate,
    CAST(NULL AS DECIMAL (19,2))                           AS montant_attendu,
    CAST(COUNT(*) AS INT)                                  AS lignes
FROM dbo.ecriture e
INNER JOIN dbo.lot_ecritures l ON l.id = e.lot_id
LEFT JOIN  dbo.ecriture_axe  x ON x.ecriture_id = e.id
WHERE e.compte_num IN ('252', '254', '256', '258')
  AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
  AND x.code_actif IS NULL
GROUP BY e.compte_num, l.arrete;

GO

