
-- 4. C89 : L'INVENTAIRE RAPPROCHE DU BILAN, par vehicule et arrete porteur de balance. Trois rapprochements :
-- le prix de revient des immeubles (inventaire) et le solde des comptes 21, 22 et 23 ; leur valeur actuelle et la ligne
-- A_IMMO_1 ; la valeur actuelle des titres des filiales et les lignes A_IMMO_3 et A_IMMO_4. ATTENDU zero ; le controle
-- ne corrige rien.
CREATE   VIEW dbo.v_controle_inventaire_bilan AS
WITH a AS (SELECT entite, arrete FROM dbo.v_arrete_etat WHERE porte_balance = 1),
cout AS (
    SELECT lo.entite, lo.arrete, SUM(e.debit - e.credit) AS solde
    FROM dbo.v_ecriture_normalisee e JOIN dbo.lot_ecritures lo ON lo.id = e.lot_id
    WHERE lo.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE') AND (e.compte_num LIKE '21%' OR e.compte_num LIKE '22%' OR e.compte_num LIKE '23%')
    GROUP BY lo.entite, lo.arrete
),
imm AS (SELECT entite, arrete, SUM(prix_de_revient) AS prix_de_revient, SUM(valeur_actuelle) AS valeur_actuelle
        FROM dbo.v_inventaire_immeubles GROUP BY entite, arrete),
fil AS (SELECT entite, arrete, SUM(valeur_actuelle_titres) AS valeur FROM dbo.v_inventaire_filiales GROUP BY entite, arrete),
bil AS (SELECT entite, arrete,
               SUM(CASE WHEN code = 'A_IMMO_1' THEN exercice_n END) AS immeubles,
               SUM(CASE WHEN code IN ('A_IMMO_3', 'A_IMMO_4') THEN exercice_n END) AS titres
        FROM dbo.v_ligne_etat_montant WHERE code IN ('A_IMMO_1', 'A_IMMO_3', 'A_IMMO_4') GROUP BY entite, arrete),
r AS (
    SELECT a.entite, a.arrete, N'Prix de revient des immeubles' AS rapprochement,
           CAST(ISNULL(imm.prix_de_revient, 0) AS DECIMAL (19, 2)) AS inventaire, CAST(ISNULL(cout.solde, 0) AS DECIMAL (19, 2)) AS bilan,
           N'inventaire 336-2 et comptes 21, 22 et 23' AS rapproche
    FROM a LEFT JOIN imm ON imm.entite = a.entite AND imm.arrete = a.arrete LEFT JOIN cout ON cout.entite = a.entite AND cout.arrete = a.arrete
    UNION ALL
    SELECT a.entite, a.arrete, N'Valeur actuelle des immeubles',
           CAST(ISNULL(imm.valeur_actuelle, 0) AS DECIMAL (19, 2)), CAST(ISNULL(bil.immeubles, 0) AS DECIMAL (19, 2)),
           N'inventaire 336-2 et ligne du bilan A_IMMO_1'
    FROM a LEFT JOIN imm ON imm.entite = a.entite AND imm.arrete = a.arrete LEFT JOIN bil ON bil.entite = a.entite AND bil.arrete = a.arrete
    UNION ALL
    SELECT a.entite, a.arrete, N'Valeur actuelle des titres des filiales',
           CAST(ISNULL(fil.valeur, 0) AS DECIMAL (19, 2)), CAST(ISNULL(bil.titres, 0) AS DECIMAL (19, 2)),
           N'inventaire 336-2 et lignes du bilan A_IMMO_3 et A_IMMO_4'
    FROM a LEFT JOIN fil ON fil.entite = a.entite AND fil.arrete = a.arrete LEFT JOIN bil ON bil.entite = a.entite AND bil.arrete = a.arrete
)
SELECT entite, arrete, rapprochement, inventaire, bilan, CAST(inventaire - bilan AS DECIMAL (19, 2)) AS ecart, rapproche,
       N'l''inventaire ne se rapproche pas du bilan : un mouvement d''actif manque ou une écriture n''a pas sa contrepartie à l''inventaire' AS lecture
FROM r
WHERE ABS(inventaire - bilan) > 0.005;

GO

