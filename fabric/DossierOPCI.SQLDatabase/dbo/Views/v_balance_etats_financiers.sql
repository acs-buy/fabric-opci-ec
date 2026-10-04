
-- 2. LA BALANCE DE L'ONGLET, AVANT LE VIREMENT DE CLOTURE.
CREATE   VIEW dbo.v_balance_etats_financiers AS
WITH mouvement AS (
    -- les lots decides, hors virement de cloture (feuille AFF-) : la balance justifie le compte de resultat
    SELECT lo.entite, lo.arrete, e.compte_num, SUM(e.debit) AS debit, SUM(e.credit) AS credit
    FROM dbo.v_ecriture_normalisee e JOIN dbo.lot_ecritures lo ON lo.id = e.lot_id
    WHERE lo.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE') AND ISNULL(lo.feuille_cote, '') NOT LIKE 'AFF-%'
    GROUP BY lo.entite, lo.arrete, e.compte_num
),
compte AS (
    SELECT a.entite, a.arrete, a.porte_balance, a.arrete_n_1, a.porte_balance_n_1, m.compte_num
    FROM dbo.v_arrete_etat a JOIN mouvement m ON m.entite = a.entite AND m.arrete = a.arrete
    UNION
    SELECT a.entite, a.arrete, a.porte_balance, a.arrete_n_1, a.porte_balance_n_1, m.compte_num
    FROM dbo.v_arrete_etat a JOIN mouvement m ON m.entite = a.entite AND m.arrete = a.arrete_n_1
)
SELECT c.entite, c.arrete, c.compte_num,
       COALESCE(r.libelle_complet, r.libelle) AS libelle,
       -- REGLE 0.4 : un arrete sans balance chargee rend NULL, « à remplir », jamais 0,00
       CAST(CASE WHEN c.porte_balance = 1 THEN ISNULL(n.debit, 0) END AS DECIMAL (19, 2)) AS debit,
       CAST(CASE WHEN c.porte_balance = 1 THEN ISNULL(n.credit, 0) END AS DECIMAL (19, 2)) AS credit,
       CAST(CASE WHEN c.porte_balance = 1 THEN ISNULL(n.debit, 0) - ISNULL(n.credit, 0) END AS DECIMAL (19, 2)) AS solde_n,
       CAST(CASE WHEN c.porte_balance_n_1 = 1 THEN ISNULL(p.debit, 0) - ISNULL(p.credit, 0) END AS DECIMAL (19, 2)) AS solde_n_1
FROM compte c
LEFT JOIN mouvement n ON n.entite = c.entite AND n.arrete = c.arrete AND n.compte_num = c.compte_num
LEFT JOIN mouvement p ON p.entite = c.entite AND p.arrete = c.arrete_n_1 AND p.compte_num = c.compte_num
LEFT JOIN dbo.ref_compte r ON r.compte = c.compte_num;

GO

