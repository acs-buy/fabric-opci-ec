-- 90. VOUS INSCRIRE AUX MISSIONS DE DEMONSTRATION.
--
-- A JOUER APRES LE CHARGEMENT, ET A MODIFIER AVANT DE LE JOUER.
--
-- POURQUOI CE SCRIPT EXISTE
--     Le depot n'emporte aucune identite. Les colonnes qui disaient qui tient quel role ont ete
--     remplacees par une valeur neutre, « installation », pour qu'aucune adresse de personne ne
--     parte dans un depot public.
--
--     Consequence, mesuree le 26/09/2026 sur une installation reelle : tant que vous n'avez pas
--     joue ce script, l'ecran du reviseur est VIDE et aucun visa n'est possible.
--
--       - la securite au niveau des lignes du modele de conduite ne montre a chacun que les
--         entites sur lesquelles il detient un mandat vivant. Aucun mandat ne porte votre
--         adresse : vous ne voyez donc aucun dossier ;
--       - la base refuse un visa a qui ne detient pas un role habilite a viser.
--
--     Aucun message ne le dit. L'ecran est simplement vide.
--
-- CE QU'IL FAIT
--     Il inscrit deux personnes sur les 16 entites de demonstration : vous, comme ASSOCIE, et un
--     second compte, comme CHEF DE MISSION.
--
--     CET ORDRE N'EST PAS ARBITRAIRE, il se lit dans la base, et l'avoir inverse a produit un refus
--     le 26/09/2026 : « la modification de ce referentiel du cabinet demande le role associe ».
--       - creer un dossier client ecrit dans ref_entite, et cette table se tient au role ASSOCIE ;
--       - les 2 roles portent « vise = 1 » dans ref_role : l'un et l'autre peuvent approuver ;
--       - la base refuse l'approbation a celui qui a soumis. Sans second compte, vous ne pouvez
--         donc pas mener un dossier jusqu'a son visa.
--
-- CE QU'IL NE FAIT PAS
--     Il ne touche pas aux roles deja poses a votre nom : il ne les pose que s'ils manquent.
--     Rejouez-le sans crainte.

-- ============================================================================
-- A REMPLIR : les deux adresses de connexion, celles avec lesquelles vous ouvrez Fabric.
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

-- LE ROLE SE REPREND, IL NE S'AJOUTE PAS.
-- La base refuse deux titulaires d'un meme role sur une meme entite en meme temps, par le
-- declencheur tr_role_sans_chevauchement : « Un role ne se partage pas dans le temps. » Les
-- mandats de demonstration existent deja, au nom neutre « installation ». Ce script les reprend
-- a votre nom plutot que d'en ouvrir de nouveaux, ce qui conserve aussi les visas deja poses.
-- Mesure le 26/09/2026, apres le refus du declencheur.

-- Le filtre ne touche que les mandats neutres et les votres : un mandat pose au nom d'un tiers
-- reel n'est jamais repris, et le script se rejoue sans effet de bord.
UPDATE dbo.role_mission
   SET personne = @vous, connexion = @vous
 WHERE role IN ('ASSOCIE', 'PREPARATEUR')
   AND (personne LIKE N'installation%' OR personne IN (@vous, @second));

UPDATE dbo.role_mission
   SET personne = @second, connexion = @second
 WHERE role = 'CHEF_MISSION'
   AND (personne LIKE N'installation%' OR personne IN (@vous, @second));

-- Ce que vous devez lire : vos deux adresses, et le nombre d'entites en face de chaque role.
SELECT r.personne AS qui, r.role AS role, COUNT(*) AS entites
  FROM dbo.role_mission r
 WHERE r.personne IN (@vous, @second)
 GROUP BY r.personne, r.role
 ORDER BY r.role;

-- Ce qui doit valoir zero : aucun mandat ne doit rester au nom neutre.
SELECT 'mandats encore au nom neutre' AS quoi, COUNT(*) AS nb
  FROM dbo.role_mission WHERE personne LIKE N'installation%';
GO
