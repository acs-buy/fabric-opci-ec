
-- --- 5d : le pilotage, societe par societe du groupe --------------------------
-- Decision du candidat du 06/09/2026 : une page « Le pilotage » regroupe ce que les
-- 4 rapports client du corps promettaient, sur ce que la base porte reellement :
-- tresorerie, emprunts, avances intragroupe, loyers, charges d'entretien, interets,
-- resultat locatif, rendement locatif. Ce qu'elle ne porte pas et que la page ne
-- montre pas : taux d'occupation, balance agee, DSO, echeancier des baux.
-- La colonne entite est la tete de groupe, pour que la securite de niveau ligne
-- du client laisse passer ses filiales ; societe est la societe lue.
-- Les comptes sont ceux du plan du modele, lus par v_ecriture_normalisee : 511
-- tresorerie, 512 emprunts (bancaire sans tiers, intragroupe avec tiers), 266
-- avances, 721 loyers, 624 entretien, 623 interets. Les comptes de gestion se
-- lisent hors des lots d'affectation, comme au 108.
CREATE   VIEW dbo.v_client_pilotage_societe AS
WITH perimetre AS (
    SELECT r.entite AS mere, r.entite AS societe, r.arrete, CAST(1 AS DECIMAL (9,6)) AS quote_part
    FROM dbo.ref_arrete r JOIN dbo.ref_entite e ON e.code = r.entite
    WHERE r.porte_balance = 1 AND e.forme_vehicule IS NOT NULL
    UNION ALL
    SELECT d.entite_mere, d.entite_fille, d.arrete, d.quote_part
    FROM dbo.detention d JOIN dbo.ref_arrete r ON r.entite = d.entite_fille AND r.arrete = d.arrete
    WHERE r.porte_balance = 1
),
solde AS (
    SELECT l.entite, l.arrete, e.compte_num, e.comp_aux_num,
           SUM(e.debit - e.credit) AS solde
    FROM dbo.v_ecriture_normalisee e
    JOIN dbo.lot_ecritures l ON l.id = e.lot_id
    WHERE l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE') AND l.famille <> 'DERIVABLE'
      AND (l.feuille_cote IS NULL OR l.feuille_cote NOT LIKE 'AFF-%')
    GROUP BY l.entite, l.arrete, e.compte_num, e.comp_aux_num
),
agrege AS (
    SELECT s.entite, s.arrete,
           SUM(CASE WHEN s.compte_num LIKE '511%' THEN s.solde ELSE 0 END)                                    AS tresorerie,
           SUM(CASE WHEN s.compte_num LIKE '512%' AND s.comp_aux_num IS NULL THEN -s.solde ELSE 0 END)        AS emprunt_bancaire,
           SUM(CASE WHEN s.compte_num LIKE '512%' AND s.comp_aux_num IS NOT NULL THEN -s.solde ELSE 0 END)    AS dette_intragroupe,
           SUM(CASE WHEN s.compte_num LIKE '266%' THEN s.solde ELSE 0 END)                                    AS avances_versees,
           SUM(CASE WHEN s.compte_num LIKE '721%' THEN -s.solde ELSE 0 END)                                   AS loyers,
           SUM(CASE WHEN s.compte_num LIKE '624%' THEN s.solde ELSE 0 END)                                    AS charges_entretien,
           SUM(CASE WHEN s.compte_num LIKE '623%' THEN s.solde ELSE 0 END)                                    AS interets,
           SUM(CASE WHEN s.compte_num LIKE '61%' THEN s.solde ELSE 0 END)                                     AS frais_fonctionnement,
           SUM(CASE WHEN s.compte_num LIKE '724%' THEN -s.solde ELSE 0 END)                                   AS interets_recus,
           SUM(CASE WHEN s.compte_num LIKE '73%' THEN -s.solde ELSE 0 END)                                    AS dividendes_recus
    FROM solde s GROUP BY s.entite, s.arrete
),
immeubles AS (
    SELECT a.entite_detentrice AS societe, x.date_valeur,
           SUM(x.valeur_actuelle) AS valeur_actuelle_immeubles, COUNT(*) AS immeubles
    FROM dbo.expertise x JOIN dbo.actif a ON a.code = x.code_actif
    WHERE a.nature = 'IMMEUBLE'
    GROUP BY a.entite_detentrice, x.date_valeur
)
SELECT p.mere + '|' + p.arrete AS cle_arrete, p.mere AS entite, p.arrete,
       p.societe, e.denomination, p.quote_part,
       CASE WHEN p.societe = p.mere THEN N'Tête de groupe' ELSE N'Filiale' END AS role,
       CAST(COALESCE(g.tresorerie, 0) AS DECIMAL (19,2))           AS tresorerie,
       CAST(COALESCE(g.emprunt_bancaire, 0) AS DECIMAL (19,2))     AS emprunt_bancaire,
       CAST(COALESCE(g.dette_intragroupe, 0) AS DECIMAL (19,2))    AS dette_intragroupe,
       CAST(COALESCE(g.avances_versees, 0) AS DECIMAL (19,2))      AS avances_versees,
       CAST(COALESCE(g.loyers, 0) AS DECIMAL (19,2))               AS loyers,
       CAST(COALESCE(g.charges_entretien, 0) AS DECIMAL (19,2))    AS charges_entretien,
       CAST(COALESCE(g.interets, 0) AS DECIMAL (19,2))             AS interets,
       CAST(COALESCE(g.frais_fonctionnement, 0) AS DECIMAL (19,2)) AS frais_fonctionnement,
       CAST(COALESCE(g.interets_recus, 0) AS DECIMAL (19,2))       AS interets_recus,
       CAST(COALESCE(g.dividendes_recus, 0) AS DECIMAL (19,2))     AS dividendes_recus,
       CAST(COALESCE(g.loyers, 0) - COALESCE(g.charges_entretien, 0) - COALESCE(g.interets, 0) AS DECIMAL (19,2))
                                                                   AS resultat_locatif,
       CAST(COALESCE(i.valeur_actuelle_immeubles, 0) AS DECIMAL (19,2)) AS valeur_actuelle_immeubles,
       COALESCE(i.immeubles, 0)                                    AS immeubles,
       CAST(CASE WHEN COALESCE(i.valeur_actuelle_immeubles, 0) = 0 THEN NULL
                 ELSE COALESCE(g.loyers, 0) / i.valeur_actuelle_immeubles END AS DECIMAL (9,6)) AS rendement_locatif
FROM perimetre p
JOIN dbo.ref_entite e ON e.code = p.societe
LEFT JOIN agrege g ON g.entite = p.societe AND g.arrete = p.arrete
LEFT JOIN immeubles i ON i.societe = p.societe AND i.date_valeur = CONVERT(DATE, p.arrete);

GO

