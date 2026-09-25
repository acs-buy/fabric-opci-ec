CREATE   VIEW dbo.v_controle_flux_vs_ecritures AS
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
FROM dbo.flux_intragroupe f
-- UN ARRETE SANS BALANCE N EST PAS RAPPROCHABLE. Les arretes de 2026 ne
-- portent aucune ecriture : leurs 48 flux ressortaient en ecart alors
-- qu ils sont seulement a venir.
JOIN dbo.ref_arrete r ON r.entite = f.entite_debitrice
                     AND r.arrete = f.arrete
                     AND r.porte_balance = 1
OUTER APPLY (
    -- LA GRANDEUR QUI SE COMPARE DEPEND DE LA CLASSE DU COMPTE. Un
    -- compte de bilan se lit par son solde ; un compte de charges ou de
    -- produits, solde a zero par la determination du resultat, se lit
    -- par son MOUVEMENT, et les ecritures de solde en sont ecartees.
    SELECT CASE WHEN f.compte_debiteur LIKE '6%'
                THEN SUM(CASE WHEN e.ecriture_num <> 'DET'
                              THEN e.debit ELSE 0 END)
                WHEN f.compte_debiteur LIKE '7%'
                THEN SUM(CASE WHEN e.ecriture_num <> 'DET'
                              THEN e.credit ELSE 0 END)
                ELSE ABS(SUM(e.debit) - SUM(e.credit)) END AS grandeur
    FROM dbo.v_ecriture_normalisee e
    WHERE e.entite = f.entite_debitrice AND e.arrete = f.arrete
      AND e.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
      -- LES 2 COMPTES SE LISENT DANS LE MEME PLAN. dbo.flux_intragroupe
      -- designe tantot un compte du modele, le 623 des charges
      -- d'emprunt, tantot un compte du plan d'une filiale, le 4551. Les
      -- 2 se ramenent au modele avant d'etre compares, faute de quoi le
      -- 4551 d'un flux ne rencontre jamais le 512 d'une ecriture.
      AND e.compte_num LIKE
          dbo.fn_compte_du_modele(f.entite_debitrice, f.compte_debiteur)
          + '%'
      -- ET L'AUXILIAIRE ISOLE L'INTERNE. Le compte 623 du modele porte
      -- aussi les interets bancaires : sans ce filtre, le flux
      -- intragroupe se comparerait a la totalite des charges d'emprunt.
      -- Le filtre ne joue que si une ecriture porte cet auxiliaire, un
      -- compte de bilan comme le 4551 n'en portant pas toujours.
      AND (e.comp_aux_num = f.entite_creditrice
           OR NOT EXISTS (SELECT 1 FROM dbo.v_ecriture_normalisee z
                          WHERE z.entite = f.entite_debitrice
                            AND z.arrete = f.arrete
                            AND z.comp_aux_num = f.entite_creditrice
                            AND z.compte_num LIKE
                                dbo.fn_compte_du_modele(
                                    f.entite_debitrice,
                                    f.compte_debiteur) + '%'))
) AS chez_debiteur
OUTER APPLY (
    SELECT CASE WHEN f.compte_crediteur LIKE '6%'
                THEN SUM(CASE WHEN e.ecriture_num <> 'DET'
                              THEN e.debit ELSE 0 END)
                WHEN f.compte_crediteur LIKE '7%'
                THEN SUM(CASE WHEN e.ecriture_num <> 'DET'
                              THEN e.credit ELSE 0 END)
                ELSE ABS(SUM(e.debit) - SUM(e.credit)) END AS grandeur
    FROM dbo.v_ecriture_normalisee e
    WHERE e.entite = f.entite_creditrice AND e.arrete = f.arrete
      AND e.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
      AND e.compte_num LIKE
          dbo.fn_compte_du_modele(f.entite_creditrice, f.compte_crediteur)
          + '%'
) AS chez_crediteur
GROUP BY f.arrete, f.nature, f.entite_debitrice, f.entite_creditrice,
         chez_debiteur.grandeur, chez_crediteur.grandeur;

GO

