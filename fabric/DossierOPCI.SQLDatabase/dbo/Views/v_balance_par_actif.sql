

-- v_balance_par_actif : balance descendue a l'axe actif, article 336-2
CREATE   VIEW v_balance_par_actif AS
SELECT
    l.arrete,
    l.entite,
    ax.code_actif,
    a.nature,
    e.compte_num                                     AS compte,
    MAX(COALESCE(c.libelle_complet, c.libelle))      AS libelle,
    SUM(CASE WHEN l.famille = 'DECIDEE'
                  AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
             THEN e.debit - e.credit ELSE 0 END)      AS od_revision,
    SUM(CASE WHEN l.famille = 'DERIVABLE'
                  AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
             THEN e.debit - e.credit ELSE 0 END)      AS od_valorisation
FROM ecriture e
JOIN lot_ecritures l  ON l.id = e.lot_id
JOIN ecriture_axe ax  ON ax.ecriture_id = e.id
JOIN ref_compte    c  ON c.compte = e.compte_num
LEFT JOIN actif    a  ON a.code = ax.code_actif
WHERE ax.code_actif IS NOT NULL
GROUP BY l.arrete, l.entite, ax.code_actif, a.nature, e.compte_num;

GO

