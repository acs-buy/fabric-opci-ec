
-- --- 5f : le compte de resultat locatif, immeuble par immeuble -------------------
-- Demande du candidat du 06/09/2026 : les lignes de l'activite locative portent l'axe
-- de l'immeuble (script 145 et 67). La vue lit les ecritures par axe : loyers 721,
-- entretien 624, interets d'emprunt 623, hors lots d'affectation et de valorisation,
-- et rapproche la valeur actuelle de l'expertise a l'arrete.
CREATE   VIEW dbo.v_client_pnl_immeuble AS
WITH perimetre AS (
    SELECT r.entite AS mere, r.entite AS societe, r.arrete, CAST(1 AS DECIMAL (9,6)) AS quote_part
    FROM dbo.ref_arrete r JOIN dbo.ref_entite e ON e.code = r.entite
    WHERE r.porte_balance = 1 AND e.forme_vehicule IS NOT NULL
    UNION ALL
    SELECT d.entite_mere, d.entite_fille, d.arrete, d.quote_part
    FROM dbo.detention d JOIN dbo.ref_arrete r ON r.entite = d.entite_fille AND r.arrete = d.arrete
    WHERE r.porte_balance = 1
),
lignes AS (
    SELECT l.entite, l.arrete, a.code_actif,
           SUM(CASE WHEN e.compte_num LIKE '721%' THEN e.credit - e.debit ELSE 0 END) AS loyers,
           SUM(CASE WHEN e.compte_num LIKE '624%' THEN e.debit - e.credit ELSE 0 END) AS charges_entretien,
           SUM(CASE WHEN e.compte_num LIKE '623%' THEN e.debit - e.credit ELSE 0 END) AS interets
    FROM dbo.v_ecriture_normalisee e
    JOIN dbo.lot_ecritures l ON l.id = e.lot_id
    JOIN dbo.ecriture_axe a ON a.ecriture_id = e.ecriture_id
    WHERE l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE') AND l.famille <> 'DERIVABLE'
      AND (l.feuille_cote IS NULL OR l.feuille_cote NOT LIKE 'AFF-%')
      AND (e.compte_num LIKE '721%' OR e.compte_num LIKE '624%' OR e.compte_num LIKE '623%')
    GROUP BY l.entite, l.arrete, a.code_actif
)
SELECT p.mere + '|' + p.arrete AS cle_arrete, p.mere AS entite, p.arrete,
       p.societe, en.denomination AS societe_libelle, p.quote_part,
       ac.code AS code_actif, ac.adresse,
       CASE WHEN ac.adresse LIKE '%,%' THEN LTRIM(RIGHT(ac.adresse, CHARINDEX(',', REVERSE(ac.adresse)) - 1)) END AS commune,
       ac.secteur, ac.surface_m2,
       CAST(li.loyers AS DECIMAL (19,2)) AS loyers,
       CAST(li.charges_entretien AS DECIMAL (19,2)) AS charges_entretien,
       CAST(li.interets AS DECIMAL (19,2)) AS interets,
       CAST(li.loyers - li.charges_entretien - li.interets AS DECIMAL (19,2)) AS resultat_locatif,
       x.valeur_actuelle,
       CAST(CASE WHEN x.valeur_actuelle IS NULL OR x.valeur_actuelle = 0 THEN NULL
                 ELSE li.loyers / x.valeur_actuelle END AS DECIMAL (9,6)) AS rendement_locatif,
       CAST(CASE WHEN ac.surface_m2 IS NULL OR ac.surface_m2 = 0 THEN NULL
                 ELSE li.loyers / ac.surface_m2 END AS DECIMAL (19,2)) AS loyer_par_m2
FROM perimetre p
JOIN dbo.ref_entite en ON en.code = p.societe
JOIN dbo.actif ac ON ac.entite_detentrice = p.societe AND ac.nature = 'IMMEUBLE'
LEFT JOIN lignes li ON li.entite = p.societe AND li.arrete = p.arrete AND li.code_actif = ac.code
LEFT JOIN dbo.expertise x ON x.code_actif = ac.code AND x.date_valeur = CONVERT(DATE, p.arrete);

GO

