

-- 3. LE MONTANT D'UNE LIGNE DETAIL, a un arrete. Un compte qui repond a 2 racines d'une meme ligne
-- ne compte qu'une fois.
CREATE   VIEW dbo.v_ligne_etat_detail AS
WITH solde AS (
    SELECT lo.entite, lo.arrete, e.compte_num,
           SUM(CASE WHEN lo.feuille_cote LIKE 'AFF-%' THEN 0 ELSE e.debit - e.credit END) AS solde_hors_aff,
           SUM(e.debit - e.credit) AS solde
    FROM dbo.v_ecriture_normalisee e
    JOIN dbo.lot_ecritures lo ON lo.id = e.lot_id
    WHERE lo.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
    GROUP BY lo.entite, lo.arrete, e.compte_num
),
compte_ligne AS (
    SELECT DISTINCT l.etat, l.code, l.sens, s.entite, s.arrete, s.compte_num,
           CASE WHEN l.etat = 'RESULTAT' AND s.compte_num LIKE '[67]%' THEN s.solde_hors_aff ELSE s.solde END AS solde
    FROM dbo.ref_ligne_etat l
    CROSS APPLY STRING_SPLIT(l.racines, ',') r
    JOIN solde s ON s.compte_num LIKE LTRIM(RTRIM(r.value)) + '%'
    WHERE l.type_ligne = 'DETAIL' AND l.racines IS NOT NULL
    UNION
    -- le resultat de la periode, solde net des classes 6 et 7 de tous les lots, au passif
    SELECT 'BILAN_PASSIF', 'P_CP_4', 'CREDIT', s.entite, s.arrete, s.compte_num, s.solde
    FROM solde s WHERE s.compte_num LIKE '[67]%'
)
SELECT etat, code, entite, arrete,
       CAST(SUM(CASE WHEN sens = 'DEBIT' THEN solde ELSE -solde END) AS DECIMAL (19, 2)) AS montant
FROM compte_ligne
GROUP BY etat, code, entite, arrete;

GO

