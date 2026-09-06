
-- --- depuis 63_SQL/127_valeur_historique_des_filiales.sql : v_controle_filiale_reevaluee ---
-- C80 : une filiale qui porterait malgre tout un ecart de valorisation.
-- La regle du dossier l'interdit, et le controle la nomme.
CREATE   VIEW dbo.v_controle_filiale_reevaluee AS
SELECT l.entite, l.arrete, e.compte_num,
       SUM(e.debit) - SUM(e.credit)        AS solde,
       N'cette entité est une filiale, tenue en valeur historique : aucun écart de valorisation ne doit y être comptabilisé, il appartient à la mère au compte 275'
                                           AS lecture
FROM dbo.v_ecriture_normalisee e
JOIN dbo.lot_ecritures l ON l.id = e.lot_id
JOIN (SELECT DISTINCT entite_fille FROM dbo.detention) d
  ON d.entite_fille = l.entite
WHERE l.famille = 'DERIVABLE'
  AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
  AND e.compte_num LIKE '27%'
GROUP BY l.entite, l.arrete, e.compte_num
HAVING SUM(e.debit) - SUM(e.credit) <> 0;

GO

