-- 203 : la dimension des arretes couvre desormais TOUT arrete qu'une table reference.
--
-- MOTIF, mesure le 15/09/2026 par la session Fabric IQ apres la pose des 16 relations d'arrete :
-- 10 lignes de 4 vues tombaient sous un membre vide de la dimension, faute d'y trouver leur
-- arrete. Deux dates manquaient, le 31/12/2026 et le 30/06/2025.
--
-- LA CAUSE EST UN DEFAUT DE CETTE VUE, PAS UN ECART DE DONNEES. Elle unissait 4 tables choisies
-- a la main, lot_ecritures, feuille_travail, arrete_mission et parts_en_circulation, alors que
-- 33 tables de la base portent une colonne « arrete ». Une dimension batie sur un sous-ensemble
-- des faits laisse forcement des faits dehors, et un fait range sous un membre vide n'est atteint
-- par aucun segment : il disparait de l'ecran sans prevenir.
--
-- LE 30/06/2025 MERITE D'ETRE NOMME : c'est un arrete SEMESTRIEL, et l'ancienne vue n'en portait
-- qu'un seul, le 30/06/2026. La solution admet donc des arretes intermediaires, et une dimension
-- qui ne connait que les clotures de decembre les perdrait tous.
--
-- CE QUE LE SCRIPT NE FAIT PAS : il n'ecrit aucune donnee, ne cree aucun arrete et ne corrige
-- aucune ligne. Il elargit la LECTURE de la dimension a ce que la base porte deja.
--
-- CE QU'IL NE REGLE PAS, ET C'EST UN ARBITRAGE A PART : 3 lignes de v_mes_refus ne portent AUCUN
-- arrete. Aucune dimension ne les rattachera. La decision retenue est de ne PAS relier
-- « Mes refus » a la dimension d'arrete : c'est la liste personnelle du reviseur, pas celle de
-- l'arrete, et un refus doit rester visible meme s'il n'est rattache a rien.
--
-- REJOUABLE : CREATE OR ALTER.

CREATE   VIEW dbo.v_dim_arrete AS
-- Le filtre sur NULL est indispensable : au moins une table porte une ligne sans
-- arrete, et un membre NULL dans une dimension ouvre une ligne vide dans le segment,
-- que le reviseur ne saurait pas interpreter. Releve a la premiere execution.
SELECT arrete FROM dbo.arrete_mission WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.attestation WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.cours_titre WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.demande_document WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.demande_reevaluation WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.derogation WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.detention WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.dip WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.document_produit WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.ecriture_brouillon WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.evaluation_actif WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.export_fec WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.feuille_travail WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.flux_intragroupe WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.import_fec WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.intention_ecriture WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.journal_refus WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.lot_ecritures WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.mouvement_actif WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.parts_en_circulation WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.piece_rattachement WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.publication_client WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.publication_vl WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.rapport_annuel WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.ref_arrete WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.ref_croisee WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.revision_compte_courant WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.saisie_annexe WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.synthese_proposee WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.valeur_instrument WHERE arrete IS NOT NULL
UNION SELECT arrete FROM dbo.visa WHERE arrete IS NOT NULL;
-- Trois tables portent un arrete et sont volontairement ecartees :
--   contexte_reviseur, qui porte le CHOIX d'un reviseur et non un fait du dossier ;
--   ref_arrete est gardee, elle est le referentiel ; tmp_jeu_hist, table de travail du jeu.

GO

