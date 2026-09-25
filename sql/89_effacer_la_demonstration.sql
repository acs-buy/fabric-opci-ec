-- Retirer le jeu de demonstration.
--
-- A JOUER QUAND VOUS PASSEZ A VOS PROPRES DOSSIERS. Le socle de referentiel n'est pas touche :
-- les questions d'acceptation, le plan de comptes, les natures de pieces et les roles restent en
-- place. Seuls les dossiers de demonstration partent.
--
-- CE QUI EST SUPPRIME, PRECISEMENT : les 16 entites de demonstration et tout ce qui s'y rattache.
-- Partout ou la table porte une colonne d'entite, la suppression les nomme une par une. Si vous
-- avez deja cree vos propres dossiers, ils ne sont pas touches.
--
-- CE QUI EST VIDE ENTIEREMENT : essai_saisie_grille, jeu_mention_refus, jeu_mention_retiree, mesure_reference, releve_coffre, contexte_reviseur, releve_controle, mouvement_porteur, piece, programme_journal, programme_question, rejet_import, expertise, feuille_piece, feuille_question, releve_coffre_refus, ecriture, export_fec_lot.
-- Ces tables ne portent aucune colonne d'entite, leur rattachement passant par un lot, une cote ou
-- un code d'actif. Les distinguer demanderait une jointure par table, et une erreur y couterait des
-- donnees. Le script les vide donc, et vous previent.
--
-- LA CONSEQUENCE, DITE FRANCHEMENT : jouez ce script AVANT de saisir vos premiers dossiers, pas
-- apres. Joue plus tard, il emporterait aussi ce que vous auriez saisi dans ces tables.
--
-- QUI PEUT JOUER CE SCRIPT : un compte portant le role d'associe sur les dossiers. La suppression
-- d'une entite est gardee par un declencheur de la base, qui refuse l'ecriture a un compte sans ce
-- role, avec le message « la modification de ce referentiel du cabinet demande le role associe ».
-- Ce n'est pas une panne : c'est la separation des fonctions, et elle s'applique ici comme ailleurs.
-- Si vous rencontrez ce refus, faites-vous designer associe sur l'ecran de conduite de mission,
-- section Equipe de la mission, puis rejouez.
--
-- L'ordre des suppressions est l'inverse de celui du chargement, afin qu'aucune cle etrangere ne
-- s'y oppose. Il couvre aussi des tables que le depot ne remplit pas : chez vous elles sont vides
-- et la suppression est sans effet, mais leurs cles etrangeres bloqueraient sinon la suppression.
-- Le script est rejouable : une seconde execution ne supprime plus rien.

SET NOCOUNT ON;
BEGIN TRANSACTION;

DECLARE @avant INT, @total INT = 0;

DELETE FROM dbo.[ecriture_axe] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[intention_ecriture] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[export_fec_lot] ;
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[evaluation_actif] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[ecriture_brouillon] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[ecriture] ;
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[demande_reevaluation] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[valeur_instrument] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[releve_coffre_refus] ;
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[ref_croisee] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[rapport_annuel] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[piece_rattachement] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2') OR [entite_couverte] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[mouvement_actif] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[lot_ecritures] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[feuille_question] ;
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[feuille_piece] ;
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[expertise] ;
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[emprunt_intragroupe] WHERE [entite_preteuse] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2') OR [entite_emprunt] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[eligibilite_participation] WHERE [entite_mere] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2') OR [entite_fille] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[derogation] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[cours_titre] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[stg_balance] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[revision_compte_courant] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2') OR [entite_fille] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[rejet_import] ;
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[ref_compte_entite] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2') OR [entite_liee] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[publication_client] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[programme_question] ;
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[programme_journal] ;
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[piece] ;
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[feuille_travail] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[conclusion_cycle] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[actif] WHERE [entite_detentrice] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2') OR [entite_liee] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[visa] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[synthese_proposee] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[saisie_annexe] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[publication_vl] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[programme_travail] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[parts_en_circulation] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[mouvement_porteur] ;
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[maintien_mission] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[import_fec] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[export_fec] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[dossier_verrou] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[document_produit] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[dip] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[detention] WHERE [entite_mere] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2') OR [entite_fille] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[conclusion_revue] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[attestation] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[arrete_mission] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[stg_fec] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[role_mission] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[releve_controle] ;
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[ref_arrete] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[porteur] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[obligation_distribution] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[flux_intragroupe] WHERE [entite_debitrice] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2') OR [entite_creditrice] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[demande_espace_client] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[demande_document] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[decision_distribution] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[contexte_reviseur] ;
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[acceptation_mission] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[releve_coffre] ;
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[ref_entite] WHERE code IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[mesure_reference] ;
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[message_ecran] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[journal_refus] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[journal_piece] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[journal_perimetre] WHERE [entite_mere] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2') OR [entite_fille] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[jeu_mention_retiree] ;
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[jeu_mention_refus] ;
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[essai_saisie_grille] ;
SET @total = @total + @@ROWCOUNT;

PRINT 'Jeu de demonstration retire : ' + CAST(@total AS VARCHAR(10)) + ' ligne(s) supprimee(s).';
PRINT 'Le socle de referentiel est intact.';

-- Relisez le compte ci-dessus. S'il vous convient, validez :
COMMIT TRANSACTION;
-- Sinon, remplacez la ligne precedente par : ROLLBACK TRANSACTION;
