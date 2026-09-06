-- =====================================================================
-- LE SOCLE DE NORMALISATION DES ECRITURES, ET LE FILET QUI PROTEGE LA
-- REPRISE DES 26 VUES.
--
-- CE QUE CE SCRIPT PREPARE. Les ecritures des filiales doivent passer au
-- plan comptable general, regle arretee le 05/09/2026. Vingt-six vues et
-- procedures lisent aujourd'hui des numeros de compte EN DUR, dans le
-- plan du modele : traduire les ecritures avant de les reprendre leur
-- ferait perdre les loyers, les charges d'emprunt et la tresorerie. La
-- reprise precede donc la traduction.
--
-- LE SOCLE. dbo.v_ecriture_normalisee rend, pour chaque ecriture, son
-- compte tel qu'il est ecrit ET le compte du modele auquel il se
-- rattache, avec toutes les colonnes que les vues consomment. Une vue
-- reprise lit ce socle et raisonne sur compte_modele : elle devient
-- indifferente au plan dans lequel l'ecriture a ete passee.
--
-- LE FILET, ET POURQUOI IL EXISTE. Reprendre 26 objets sans mesure
-- prealable reviendrait a esperer que rien ne bouge. La table
-- dbo.mesure_reference fige les grandeurs qui ne doivent PAS changer, et
-- la vue v_ecart_de_reprise les compare a leur valeur du moment. Toute
-- reprise se juge sur cette comparaison, non sur une impression.
--
-- CE QUE LE FILET NE COUVRE PAS. Il fige des grandeurs, non des
-- structures : une vue qui perdrait une colonne ou changerait un libelle
-- passerait au travers. Il couvre ce qui se chiffre, et c'est ce qui
-- porte les preuves du memoire.
-- A executer contre la BASE SQL Fabric DossierOPCI.
-- =====================================================================

-- --- 1 : le socle ---------------------------------------------------
CREATE   VIEW dbo.v_ecriture_normalisee AS
-- LE SOCLE REND TOUTES LES COLONNES DE dbo.ecriture, plus celles du lot
-- que les vues consomment. Le premier jet n'en retenait qu'une partie,
-- et 2 vues ont refuse de compiler faute de piece_ref : une colonne
-- oubliee ne se voit qu'a la compilation de la vue qui l'emploie, et le
-- filet des grandeurs figees ne la rattrape pas.
-- La colonne id est exposee sous ses 2 noms, les vues l'appelant tantot
-- id, tantot ecriture_id.
SELECT e.id                                   AS ecriture_id,
       e.id, e.lot_id,
       l.entite, l.arrete, l.famille AS famille_lot, l.statut,
       l.feuille_cote, l.question_id, l.perime_le,
       e.journal_code, e.journal_lib, e.ecriture_num, e.ecriture_date,
       e.compte_num                           AS compte_ecrit,
       e.compte_lib, e.comp_aux_num, e.comp_aux_lib,
       e.piece_ref, e.piece_date, e.ecriture_lib,
       e.debit, e.credit, e.ecriture_let, e.date_let, e.valid_date,
       e.montant_devise, e.id_devise, e.compte_origine, e.famille,
       -- LE COMPTE SUR LEQUEL UNE VUE DOIT RAISONNER.
       dbo.fn_compte_du_modele(l.entite, e.compte_num) AS compte_num,
       CAST(CASE WHEN dbo.fn_compte_du_modele(l.entite, e.compte_num)
                      <> e.compte_num THEN 1 ELSE 0 END AS BIT) AS traduit
FROM dbo.ecriture e
JOIN dbo.lot_ecritures l ON l.id = e.lot_id

GO

