CREATE   VIEW dbo.v_dim_arrete AS
-- Le filtre sur NULL est indispensable : au moins une table porte une ligne sans
-- arrete, et un membre NULL dans une dimension ouvre une ligne vide dans le segment,
-- que le reviseur ne saurait pas interpreter. Releve a la premiere execution.
-- 13/10/2026, decision du candidat : arrete_affiche, l'arrete ecrit jj/mm/aaaa, que le selecteur Arrete affiche ; trie
-- par arrete au modele. 1 valeur par arrete.
SELECT u.arrete, CAST(CONVERT(VARCHAR (10), TRY_CAST(u.arrete AS DATE), 103) AS VARCHAR (10)) AS arrete_affiche
FROM (
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
UNION SELECT arrete FROM dbo.visa WHERE arrete IS NOT NULL
) u;
-- Trois tables portent un arrete et sont volontairement ecartees :
--   contexte_reviseur, qui porte le CHOIX d'un reviseur et non un fait du dossier ;
--   ref_arrete est gardee, elle est le referentiel ; tmp_jeu_hist, table de travail du jeu.

GO

