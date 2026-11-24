-- Retirer le jeu de demonstration.
--
-- A JOUER QUAND VOUS PASSEZ A VOS PROPRES DOSSIERS. Le socle de referentiel n'est pas touche :
-- les questions d'acceptation, le plan de comptes, les natures de pieces et les roles restent en
-- place. Seuls les dossiers de demonstration partent.
--
-- CE QUI EST SUPPRIME, PRECISEMENT : les 16 entites de demonstration et les lignes qui s'y rattachent.
-- Une ligne s'y rattache par sa colonne d'entite ou, faute d'une telle colonne, par une cle etrangere
-- vers une ligne qui s'y rattache : une ecriture par son lot, une feuille par sa cote, une expertise
-- par son actif. Les grandeurs figees de mesure_reference s'y rattachent par le code d'entite qui ouvre
-- leur cle. Les lignes de vos propres dossiers ne sont pas supprimees, que vous jouiez ce script avant
-- ou apres les avoir saisies.
--
-- DANS LE SOCLE, SEULES PARTENT LES LIGNES QUI DESIGNENT UNE ENTITE DE DEMONSTRATION : ref_ratio_vehicule.
-- Leur cle etrangere bloquerait sinon la suppression de l'entite.
--
-- CE QUI N'EST PAS TOUCHE. Ces tables ne se rattachent a aucune entite et le jeu de demonstration ne
-- les remplit pas :
--    classeur_cabinet : les classeurs de referentiel deposes par votre cabinet a l'ecran Referentiels.
--    releve_controle : vos releves de controle, ecrits par EXEC dbo.pr_relever_controles.
--    releve_coffre : vos releves du coffre.
--    annexe_w_arr, annexe_w_axe, annexe_w_cel, annexe_w_ctl, annexe_w_etat, annexe_w_nom, annexe_w_num,
--      annexe_w_ops, annexe_w_sol : les lignes de travail d'un calcul de l'annexe, que le calcul efface
--      lui-meme a sa fin.
--    essai_saisie_grille : une table d'essai de la saisie dans une grille, creee vide par le depot ;
--      seules les procedures pr_essai_du_cache, pr_essai_refus_avale et pr_essai_refus_relance y ecrivent.
--    jeu_mention_refus, jeu_mention_retiree : le journal du retrait d'une mention dans les textes de la
--      base qui a servi a construire le depot, creees vides par le depot ; aucun script du depot n'y
--      ecrit.
--
-- QUI PEUT JOUER CE SCRIPT : un compte portant le role d'associe sur les dossiers. La suppression
-- d'une entite est gardee par un declencheur de la base, qui refuse l'ecriture a un compte sans ce
-- role, avec le message « la modification de ce referentiel du cabinet demande le role associe ».
-- Ce n'est pas une panne : c'est la separation des fonctions, et elle s'applique ici comme ailleurs.
-- Si vous rencontrez ce refus, faites-vous designer associe sur l'ecran de conduite de mission,
-- section Equipe de la mission, puis rejouez.
--
-- L'ordre des suppressions est l'inverse de celui du chargement, afin qu'aucune cle etrangere ne
-- s'y oppose. Il couvre aussi des tables que le depot ne remplit pas, pour les lignes que vous y
-- auriez ajoutees sur une entite de demonstration : leurs cles etrangeres bloqueraient sinon la
-- suppression. Le script est rejouable : une seconde execution ne supprime plus rien.

SET NOCOUNT ON;
BEGIN TRANSACTION;

DECLARE @avant INT, @total INT = 0;

DELETE FROM dbo.[ecriture_axe] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[intention_ecriture] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE t FROM dbo.[export_fec_lot] t WHERE EXISTS (SELECT 1 FROM dbo.[export_fec] r1 WHERE r1.[id] = t.[export_id] AND (r1.[entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2'))) OR EXISTS (SELECT 1 FROM dbo.[lot_ecritures] r2 WHERE r2.[id] = t.[lot_id] AND (r2.[entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2')));
SET @total = @total + @@ROWCOUNT;
DELETE t FROM dbo.[expertise_remplacee] t WHERE EXISTS (SELECT 1 FROM dbo.[expertise] r1 WHERE r1.[id] = t.[expertise_id] AND (EXISTS (SELECT 1 FROM dbo.[actif] r2 WHERE r2.[code] = r1.[code_actif] AND (r2.[entite_detentrice] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2') OR r2.[entite_liee] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2'))) OR EXISTS (SELECT 1 FROM dbo.[piece] r3 WHERE r3.[id] = r1.[piece_id] AND (r3.[entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2')))));
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[evaluation_actif] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[ecriture_brouillon] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE t FROM dbo.[ecriture] t WHERE EXISTS (SELECT 1 FROM dbo.[lot_ecritures] r1 WHERE r1.[id] = t.[lot_id] AND (r1.[entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2')));
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[demande_reevaluation] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[valeur_instrument] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE t FROM dbo.[releve_coffre_refus] t WHERE EXISTS (SELECT 1 FROM dbo.[piece] r1 WHERE r1.[id] = t.[piece_en_face] AND (r1.[entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2')));
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[ref_ratio_vehicule] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
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
DELETE t FROM dbo.[feuille_question] t WHERE EXISTS (SELECT 1 FROM dbo.[feuille_travail] r1 WHERE r1.[cote] = t.[cote] AND (r1.[entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2')));
SET @total = @total + @@ROWCOUNT;
DELETE t FROM dbo.[feuille_piece] t WHERE EXISTS (SELECT 1 FROM dbo.[feuille_travail] r1 WHERE r1.[cote] = t.[cote] AND (r1.[entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2'))) OR EXISTS (SELECT 1 FROM dbo.[piece] r2 WHERE r2.[id] = t.[piece_id] AND (r2.[entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2')));
SET @total = @total + @@ROWCOUNT;
DELETE t FROM dbo.[expertise] t WHERE EXISTS (SELECT 1 FROM dbo.[actif] r1 WHERE r1.[code] = t.[code_actif] AND (r1.[entite_detentrice] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2') OR r1.[entite_liee] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2'))) OR EXISTS (SELECT 1 FROM dbo.[piece] r2 WHERE r2.[id] = t.[piece_id] AND (r2.[entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2')));
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
DELETE t FROM dbo.[rejet_import] t WHERE EXISTS (SELECT 1 FROM dbo.[import_fec] r1 WHERE r1.[id] = t.[import_id] AND (r1.[entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2')));
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[ref_compte_entite] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2') OR [entite_liee] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[publication_client] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE t FROM dbo.[programme_question] t WHERE EXISTS (SELECT 1 FROM dbo.[programme_travail] r1 WHERE r1.[id] = t.[programme_id] AND (r1.[entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2')));
SET @total = @total + @@ROWCOUNT;
DELETE t FROM dbo.[programme_journal] t WHERE EXISTS (SELECT 1 FROM dbo.[programme_travail] r1 WHERE r1.[id] = t.[programme_id] AND (r1.[entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2')));
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[piece] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[feuille_travail] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE t FROM dbo.[document_couverture] t WHERE EXISTS (SELECT 1 FROM dbo.[document_produit] r1 WHERE r1.[id] = t.[document_couvert_id] AND (r1.[entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2'))) OR EXISTS (SELECT 1 FROM dbo.[document_produit] r2 WHERE r2.[id] = t.[document_id] AND (r2.[entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2')));
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[demande_reouverture] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[decision_distribution] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE t FROM dbo.[copie_livrable] t WHERE EXISTS (SELECT 1 FROM dbo.[document_produit] r1 WHERE r1.[id] = t.[document_id] AND (r1.[entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2')));
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[conclusion_ratio] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
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
DELETE FROM dbo.[od_retrait] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[od_reimport] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE t FROM dbo.[mouvement_porteur] t WHERE EXISTS (SELECT 1 FROM dbo.[porteur] r1 WHERE r1.[id] = t.[porteur_id] AND (r1.[entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2')));
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
DELETE FROM dbo.[ref_arrete] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[porteur] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[obligation_distribution] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[flux_intragroupe] WHERE [entite_debitrice] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2') OR [entite_creditrice] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[export_dossier] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[demande_espace_client] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[demande_document] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[controle_annexe] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[contexte_reviseur] WHERE [vehicule] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[cellule_annexe] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[acceptation_mission] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[ref_entite] WHERE [code] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[mesure_reference] WHERE LEFT([cle], CHARINDEX('|', [cle] + '|') - 1) IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[message_ecran] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[journal_refus] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[journal_piece] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[journal_perimetre] WHERE [entite_mere] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2') OR [entite_fille] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[calcul_annexe] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[arrete_periodicite] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[annexe_version] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;
DELETE FROM dbo.[annexe_retard] WHERE [entite] IN ('OMEGA-OPCI', 'OMEGA-SCI-1', 'OMEGA-SCI-2', 'OMEGA-SCI-3', 'OMEGA-SCI-4', 'OMEGA-SCI-5', 'OMEGA-SCI-6', 'OMEGA-SCI-7', 'OMEGA-SCI-8', 'OMEGA-SCI-9', 'OMEGA-SCI-10', 'OMEGA-SCI-11', 'OMEGA-SCI-12', 'OPCI-1', 'SCI-NORD', 'SIGMA-SCI-2');
SET @total = @total + @@ROWCOUNT;

PRINT 'Jeu de demonstration retire : ' + CAST(@total AS VARCHAR(10)) + ' ligne(s) supprimee(s).';
PRINT 'Le socle de referentiel est intact, hors les lignes qui designaient une entite de demonstration.';

-- Relisez le compte ci-dessus. S'il vous convient, validez :
COMMIT TRANSACTION;
-- Sinon, remplacez la ligne precedente par : ROLLBACK TRANSACTION;
