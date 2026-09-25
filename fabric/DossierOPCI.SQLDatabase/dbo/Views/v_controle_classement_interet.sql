
-- --- depuis 63_SQL/94_vues_intragroupe.sql : v_controle_classement_interet -------
-- --- 7 : le controle du classement -------------------------------
-- Un interet d'emprunt affecte a un actif immobilier porte au compte 608
-- tomberait dans le resultat financier, ce que l'article 322-5 exclut.
-- ATTENDU zero.
CREATE   VIEW dbo.v_controle_classement_interet AS
SELECT i.reference, i.entite_emprunt, i.arrete, i.objet,
       i.compte_charge                                     AS compte_attendu,
       e.compte_num                                        AS compte_porte,
       e.debit, i.fondement
FROM dbo.v_interets_intragroupe i
JOIN dbo.lot_ecritures l ON l.entite = i.entite_emprunt AND l.arrete = i.arrete
                        AND l.famille = 'IMPORTEE'
JOIN dbo.v_ecriture_normalisee e ON e.lot_id = l.id AND e.piece_ref = i.reference
                   AND e.debit > 0
WHERE e.compte_num <> i.compte_charge;

GO

