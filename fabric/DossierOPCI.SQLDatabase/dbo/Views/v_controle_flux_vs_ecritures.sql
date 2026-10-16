
CREATE   VIEW dbo.v_controle_flux_vs_ecritures AS
WITH f AS (
    SELECT f.*, dbo.fn_compte_du_modele(f.entite_debitrice, f.compte_debiteur) AS compte_modele_debiteur,
           dbo.fn_compte_du_modele(f.entite_creditrice, f.compte_crediteur) AS compte_modele_crediteur
    FROM dbo.flux_intragroupe f
    JOIN dbo.ref_arrete r ON r.entite = f.entite_debitrice AND r.arrete = f.arrete AND r.porte_balance = 1
),
k AS (
    SELECT entite_debitrice AS entite, arrete FROM f UNION SELECT entite_creditrice, arrete FROM f
),
agg AS (
    SELECT e.entite, e.arrete, e.compte_num, e.comp_aux_num,
           SUM(e.debit) AS debit, SUM(e.credit) AS credit,
           SUM(CASE WHEN e.ecriture_num <> 'DET' THEN e.debit ELSE 0 END) AS debit_hors_det,
           SUM(CASE WHEN e.ecriture_num <> 'DET' THEN e.credit ELSE 0 END) AS credit_hors_det
    FROM dbo.v_ecriture_normalisee e
    JOIN k ON k.entite = e.entite AND k.arrete = e.arrete
    WHERE e.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
    GROUP BY e.entite, e.arrete, e.compte_num, e.comp_aux_num
)
SELECT f.arrete, f.nature, f.entite_debitrice, f.entite_creditrice,
       SUM(f.montant)                      AS montant_declare,
       chez_debiteur.grandeur              AS solde_chez_le_debiteur,
       chez_crediteur.grandeur             AS solde_chez_le_crediteur,
       SUM(f.montant) - COALESCE(chez_debiteur.grandeur, 0) AS ecart_debiteur,
       CASE WHEN chez_debiteur.grandeur IS NULL
            THEN N'le compte du débiteur ne porte aucune écriture : le flux est déclaratif'
            WHEN SUM(f.montant) - chez_debiteur.grandeur = 0
            THEN N'le flux déclaré égale ce que portent les écritures du débiteur'
            ELSE N'le flux déclaré diffère de ce que portent les écritures du débiteur'
            END                             AS lecture
FROM f
OUTER APPLY (
    SELECT CASE WHEN f.compte_debiteur LIKE '6%' THEN SUM(a.debit_hors_det)
                WHEN f.compte_debiteur LIKE '7%' THEN SUM(a.credit_hors_det)
                ELSE ABS(SUM(a.debit) - SUM(a.credit)) END AS grandeur
    FROM agg a
    WHERE a.entite = f.entite_debitrice AND a.arrete = f.arrete
      AND a.compte_num LIKE f.compte_modele_debiteur + '%'
      AND (a.comp_aux_num = f.entite_creditrice
           OR NOT EXISTS (SELECT 1 FROM agg z
                          WHERE z.entite = f.entite_debitrice AND z.arrete = f.arrete
                            AND z.comp_aux_num = f.entite_creditrice
                            AND z.compte_num LIKE f.compte_modele_debiteur + '%'))
) AS chez_debiteur
OUTER APPLY (
    SELECT CASE WHEN f.compte_crediteur LIKE '6%' THEN SUM(a.debit_hors_det)
                WHEN f.compte_crediteur LIKE '7%' THEN SUM(a.credit_hors_det)
                ELSE ABS(SUM(a.debit) - SUM(a.credit)) END AS grandeur
    FROM agg a
    WHERE a.entite = f.entite_creditrice AND a.arrete = f.arrete
      AND a.compte_num LIKE f.compte_modele_crediteur + '%'
) AS chez_crediteur
GROUP BY f.arrete, f.nature, f.entite_debitrice, f.entite_creditrice,
         chez_debiteur.grandeur, chez_crediteur.grandeur;

GO

