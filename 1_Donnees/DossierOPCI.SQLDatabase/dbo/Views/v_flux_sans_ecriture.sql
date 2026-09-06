
-- --- depuis 63_SQL/111_jeu_dividende_siic_et_vente_interne.sql : v_flux_sans_ecriture ---
-- C57 : un flux declare dont aucune ecriture ne porte le montant. Il
-- n'est PAS attendu a zero : le semis declare 2 flux sans ecriture, a
-- dessein, pour que l'ecran E4-2 montre une rationalisation qui ne
-- boucle pas. La vue les nomme, pour que personne ne les prenne pour
-- des ecritures manquantes par oubli.
CREATE   VIEW dbo.v_flux_sans_ecriture AS
SELECT f.arrete, f.nature, f.entite_debitrice, f.entite_creditrice,
       f.montant,
       CASE WHEN f.source LIKE N'SIMULE%'
            THEN N'déclaré sans écriture, à dessein : le semis ne touche pas aux balances arrêtées'
            ELSE N'déclaré sans écriture : vérifier la comptabilisation'
            END                              AS lecture
FROM dbo.flux_intragroupe f
-- ELLE SE BORNE AUX FLUX DECLARES A LA MAIN. Les 72 flux derives des
-- emprunts portent un ENCOURS et des interets calcules, non des
-- ecritures unitaires : les comparer ligne a ligne rendait 62 faux
-- positifs, mesure le 05/09/2026. Le rapprochement des encours se fait
-- par dbo.v_controle_flux_vs_ecritures, qui somme les 2 cotes.
WHERE f.source LIKE N'SIMULE%'
  AND NOT EXISTS (
    SELECT 1 FROM dbo.v_ecriture_normalisee e
    JOIN dbo.lot_ecritures l ON l.id = e.lot_id
    WHERE l.entite = f.entite_debitrice AND l.arrete = f.arrete
      AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
      AND e.compte_num LIKE f.compte_debiteur + '%'
      AND ABS(ABS(e.debit - e.credit) - f.montant) < 0.005);

GO

