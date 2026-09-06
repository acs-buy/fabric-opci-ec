
-- --- depuis 63_SQL/125_rapprochement_intragroupe.sql : v_flux_sans_contrepartie_comptable ---
-- --- 5 : le fait, nomme au lieu d'etre dilue ------------------------
-- C77 : les flux intragroupe DECLARES dont aucun compte ne porte trace.
-- La vue separe ce qui est un ecart de montant, qui appelle une reprise,
-- de ce qui est une absence totale d'ecriture, qui appelle une decision
-- de calibrage du jeu d'essai.
CREATE   VIEW dbo.v_flux_sans_contrepartie_comptable AS
SELECT f.arrete, f.nature, f.entite_debitrice, f.entite_creditrice,
       f.compte_debiteur, f.compte_crediteur,
       SUM(f.montant)                                 AS montant_declare,
       CAST(CASE WHEN MAX(CASE WHEN chez.solde IS NULL THEN 0 ELSE 1 END) = 0
                 THEN 1 ELSE 0 END AS BIT)            AS aucune_ecriture,
       N'le flux est déclaré par dbo.emprunt_intragroupe et aucune écriture ne le porte : la comptabilisation des comptes courants relève d''une décision de calibrage du jeu'
                                                      AS lecture
FROM dbo.flux_intragroupe f
OUTER APPLY (
    SELECT ABS(SUM(e.debit) - SUM(e.credit)) AS solde
    FROM dbo.v_ecriture_normalisee e
    JOIN dbo.lot_ecritures l ON l.id = e.lot_id
    WHERE l.entite = f.entite_debitrice AND l.arrete = f.arrete
      AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
      AND e.compte_num LIKE f.compte_debiteur + '%'
) AS chez
GROUP BY f.arrete, f.nature, f.entite_debitrice, f.entite_creditrice,
         f.compte_debiteur, f.compte_crediteur
HAVING MAX(CASE WHEN chez.solde IS NULL THEN 0 ELSE 1 END) = 0;

GO

