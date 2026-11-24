-- La vue de balance, avec ses 10 colonnes, lue sur le socle de normalisation (v_ecriture_normalisee,
-- fn_compte_du_modele).
CREATE VIEW dbo.v_balance AS
SELECT
    l.arrete,
    l.entite,
    e.compte_num                                     AS compte,
    -- LE COMPTE DU MODELE, EN PLUS ET NON A LA PLACE. Une balance
    -- est le document de son entite : elle porte le compte tel que
    -- l'entite le tient. La colonne suivante permet d'agreger les
    -- entites entre elles sans deformer ce qui est remis au client.
    MAX(cm.compte_modele) AS compte_modele,
    MAX(COALESCE(c.libelle_complet, c.libelle))      AS libelle,
    MAX(CAST(c.porte_actif AS INT))                  AS porte_actif,

    SUM(CASE WHEN l.famille = 'IMPORTEE'
                  AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
             THEN e.debit - e.credit ELSE 0 END)      AS b0_initiale,

    SUM(CASE WHEN l.famille = 'DECIDEE'
                  AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
             THEN e.debit - e.credit ELSE 0 END)      AS od_revision,

    SUM(CASE WHEN l.famille = 'DERIVABLE'
                  AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
             THEN e.debit - e.credit ELSE 0 END)      AS od_valorisation,

    SUM(CASE WHEN l.famille = 'IMPORTEE'
                  AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
             THEN e.debit - e.credit ELSE 0 END)
  + SUM(CASE WHEN l.famille = 'DECIDEE'
                  AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
             THEN e.debit - e.credit ELSE 0 END)
  + SUM(CASE WHEN l.famille = 'DERIVABLE'
                  AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
             THEN e.debit - e.credit ELSE 0 END)      AS balance_finale,

    MAX(x.xref)                                      AS xref,
    MAX(COALESCE(x.etat, 'A_FAIRE'))                 AS etat,
    MAX(x.par)                                       AS par,
    -- date_etat, instant ou le compte a ete marque revu (pr_ecran_marquer_compte_revu, SYSUTCDATETIME), a
    -- l'heure de Paris ; aucun objet de la base ni aucune fonction ne lit v_balance.date_etat.
    MAX(CAST(x.date_etat AT TIME ZONE 'UTC' AT TIME ZONE 'Romance Standard Time' AS DATETIME2 (3))) AS date_etat
FROM ecriture e
JOIN lot_ecritures l ON l.id = e.lot_id
CROSS APPLY (SELECT CAST(CASE WHEN ISNULL((SELECT TOP (1) xe.plan_propre_en_service FROM dbo.ref_entite xe WHERE xe.code = l.entite), 0) = 0
                              AND EXISTS (SELECT 1 FROM dbo.ref_compte xc WHERE xc.compte = e.compte_num)
                         THEN e.compte_num
                         ELSE ISNULL((SELECT TOP (1) xr.compte_modele FROM dbo.ref_compte_entite xr
                                      WHERE xr.entite = l.entite AND xr.compte_entite = e.compte_num AND xr.compte_modele IS NOT NULL),
                                     e.compte_num) END AS VARCHAR (20)) AS compte_modele) cm
JOIN ref_compte    c ON c.compte = e.compte_num
LEFT JOIN ref_croisee x ON x.arrete = l.arrete
                       AND x.entite = l.entite
                       AND x.compte_num = e.compte_num
GROUP BY l.arrete, l.entite, e.compte_num;

GO

