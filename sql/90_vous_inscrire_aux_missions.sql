-- 90. VOUS INSCRIRE AUX MISSIONS DE DÉMONSTRATION.
--
-- À JOUER APRÈS LE CHARGEMENT, ET À MODIFIER AVANT DE LE JOUER.
--
-- POURQUOI CE SCRIPT EXISTE
--     Le dépôt n'emporte aucune identité. Les colonnes qui disaient qui tient quel rôle ont été
--     remplacées par une valeur neutre, « installation », pour qu'aucune adresse de personne ne
--     parte dans un dépôt public.
--
--     Conséquence, mesurée le 26/09/2026 sur une installation réelle : tant que vous n'avez pas
--     joué ce script, l'écran du réviseur est VIDE et aucun visa n'est possible.
--
--       - la sécurité au niveau des lignes du modèle de conduite ne montre à chacun que les
--         entités sur lesquelles il détient un mandat en cours. Aucun mandat ne porte votre
--         adresse : vous ne voyez donc aucun dossier ;
--       - la base refuse un visa à qui ne détient pas un rôle habilité à viser ;
--       - depuis le 15/11/2026, la base refuse aussi les actions de l'équipe (ajouter une filiale,
--         répondre au questionnaire, déposer ou retirer une pièce, entre autres) à qui ne tient aucun
--         rôle en cours sur le dossier, ni sur le véhicule qui le détient (dbo.fn_membre_equipe,
--         refus 51300 à 51321 et 51325), et le rapport grise les boutons de ces actions.
--
--     Aucun message ne le dit. L'écran est simplement vide.
--
-- CE QU'IL FAIT
--     Il reprend les mandats de démonstration des 16 entités (sql/80_demonstration/43_role_mission.sql) :
--       - vous recevez les mandats ASSOCIE et PREPARATEUR des 16 entités ;
--       - le second compte reçoit les mandats CHEF_MISSION des 16 entités.
--
--     CETTE RÉPARTITION SE LIT DANS LA BASE, et l'avoir inversée a produit un refus le 26/09/2026 :
--     « la modification de ce référentiel du cabinet demande le rôle associé ».
--       - créer ou modifier un dossier client écrit dans ref_entite. Son déclencheur
--         tr_ref_entite_garde exige le rôle ASSOCIE, sur un dossier quelconque, du compte qu'il juge :
--         l'identité posée par la procédure dans le contexte « par », à défaut le compte de la session
--         SQL. pr_creer_client et pr_modifier_client ne posent pas ce contexte, et derrière une
--         fonction de données la session SQL est celle du propriétaire de la fonction : c'est donc le
--         compte propriétaire des fonctions qui doit tenir le rôle ASSOCIE ;
--       - ref_role porte « vise = 1 » pour ASSOCIE et CHEF_MISSION, mais chaque nature de visa a son
--         rôle dans role_nature_visa (sql/10_referentiels/59_role_nature_visa.sql) : ACCEPTATION,
--         MAINTIEN, OBLIGATION et PUBLICATION se visent par l'ASSOCIE ; CLOTURE, CONCLUSION, CYCLE,
--         DEROGATION, EVALUATION, LOT, REVUE et SYNTHESE par le CHEF_MISSION. Un chef de mission qui
--         approuve une acceptation reçoit le refus 50071 ;
--       - la base refuse l'approbation de l'acceptation à celui qui a créé le dossier (50070). Celui
--         qui crée un dossier à l'écran en devient le CHEF_MISSION ; l'autre compte doit y être
--         désigné ASSOCIE, section « Équipe de la mission », avant d'approuver. Sans second compte,
--         vous ne pouvez donc pas mener un dossier jusqu'à son visa.
--
--     LE CUMUL ASSOCIE ET PREPARATEUR SUR VOTRE COMPTE a une conséquence : la base d'une
--     obligation de distribution se propose par le PREPARATEUR du véhicule (refus 50814) et se vise
--     par l'ASSOCIE, qui ne vise pas ce qu'il a proposé (refus 50057). Pour un visa favorable,
--     désignez un autre compte sur la ligne « Collaborateur » du véhicule, section « Équipe de la
--     mission », ou faites proposer la base par un 3e compte désigné ainsi.
--
-- CE QU'IL NE FAIT PAS
--     Il n'ouvre aucun mandat : il reprend les mandats au nom neutre, et ceux qui portent déjà
--     l'une de vos 2 adresses. Rejouez-le sans crainte.

-- ============================================================================
-- À REMPLIR : les 2 adresses de connexion, celles avec lesquelles vous ouvrez Fabric.
-- ============================================================================
DECLARE @vous   NVARCHAR (400) = N'vous@votre-cabinet.fr';
DECLARE @second NVARCHAR (400) = N'un-collegue@votre-cabinet.fr';
-- ============================================================================

IF @vous LIKE N'%votre-cabinet.fr' OR @second LIKE N'%votre-cabinet.fr'
BEGIN
    THROW 50900, N'Remplacez les deux adresses en tete de ce script par les votres, puis rejouez-le.', 1;
END

IF @vous = @second
BEGIN
    THROW 50901, N'Les deux adresses doivent differer : la base refuse le visa a qui l''a soumis.', 1;
END

-- LE RÔLE SE REPREND, IL NE S'AJOUTE PAS.
-- La base refuse 2 titulaires d'un même rôle sur une même entité en même temps, par le
-- déclencheur tr_role_sans_chevauchement (refus 50045). Les mandats de démonstration existent
-- déjà, au nom neutre « installation ». Ce script les reprend
-- à votre nom plutôt que d'en ouvrir de nouveaux, ce qui conserve aussi les visas déjà posés.
-- Mesuré le 26/09/2026, après le refus du déclencheur.

-- Le filtre ne touche que les mandats neutres et les vôtres : un mandat posé au nom d'un tiers
-- réel n'est jamais repris, et le script se rejoue sans effet de bord.
UPDATE dbo.role_mission
   SET personne = @vous, connexion = @vous
 WHERE role IN ('ASSOCIE', 'PREPARATEUR')
   AND (personne LIKE N'installation%' OR personne IN (@vous, @second));

UPDATE dbo.role_mission
   SET personne = @second, connexion = @second
 WHERE role = 'CHEF_MISSION'
   AND (personne LIKE N'installation%' OR personne IN (@vous, @second));

-- Ce que vous devez lire : vos 2 adresses, et le nombre d'entités en face de chaque rôle.
SELECT r.personne AS qui, r.role AS role, COUNT(*) AS entites
  FROM dbo.role_mission r
 WHERE r.personne IN (@vous, @second)
 GROUP BY r.personne, r.role
 ORDER BY r.role;

-- Ce qui doit valoir zéro : aucun mandat ne doit rester au nom neutre.
SELECT 'mandats encore au nom neutre' AS quoi, COUNT(*) AS nb
  FROM dbo.role_mission WHERE personne LIKE N'installation%';
GO
