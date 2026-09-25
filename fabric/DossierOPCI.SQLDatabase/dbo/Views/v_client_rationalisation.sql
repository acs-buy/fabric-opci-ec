-- =====================================================================
-- LES VUES DU RAPPORT CLIENT, PARCOURS P1 : LES 5 ECRANS QUE LE MODELE
-- SEMANTIQUE NE PORTAIT PAS ENCORE.
--
-- POURQUOI DES VUES DEDIEES. Le modele semantique restitution_client relie
-- toutes ses tables a la dimension v_arrete_client par une cle sur une
-- seule colonne, cle_arrete = entite|arrete, script 64. Les vues de calcul
-- que les 5 ecrans lisent, v_rationalisation_opci, v_differences_synthese,
-- v_patrimoine_valorise, v_titres_valeur_actuelle et v_ratio_arrete,
-- portent l'entite et l'arrete en 2 colonnes : chacune recoit ici une vue
-- cliente qui pose la cle, se limite aux arretes qui portent une balance,
-- et traduit en clair ce que le lecteur doit lire, libelle de famille,
-- conclusion d'un ratio, sens d'un seuil. Aucune vue de calcul n'est
-- modifiee : les vues clientes s'ajoutent et lisent.
--
-- LA RATIONALISATION EST DEPLIEE EN LIGNES. Le graphique en cascade
-- attend une ligne par cause ; v_rationalisation_opci rend une ligne par
-- arrete avec une colonne par cause. v_client_rationalisation_cause la
-- deplie, dans l'ordre de la feuille VAR ANR du classeur de valeur
-- liquidative, ouverture, causes, cloture. Les dividendes internes,
-- portes pour memoire et hors somme, sont exclus de la cascade : leur
-- montant est deja dans le resultat de la mere, cf. script 108.
--
-- L'EXEMPLE IR4 N'EST PAS DU PATRIMOINE. Les 2 actifs de l'exemple de
-- l'article 212-5, script 42, appartiennent a OMEGA-OPCI et remontent
-- dans v_patrimoine_valorise a tout arrete, 100,00 de compte courant au
-- 2025-12-31. Le rapport client les ecarte par leur code, et le dit ici.
-- A executer contre la BASE SQL Fabric DossierOPCI.
-- =====================================================================

-- --- 1 : la rationalisation, une ligne par arrete ------------------------
CREATE   VIEW dbo.v_client_rationalisation AS
SELECT o.entite + '|' + o.arrete                AS cle_arrete,
       o.entite, o.arrete, o.arrete_precedent,
       o.actif_net_precedent,
       o.actif_net_calcule                      AS actif_net_constate,
       o.actif_net_calcule - o.actif_net_precedent AS variation_constatee,
       o.actif_net_rationalise - o.actif_net_precedent AS variation_expliquee,
       c.ecart                                  AS bouclage,
       c.boucle, c.lecture, c.source_du_seuil,
       o.dividendes_internes_pour_memoire
FROM dbo.v_rationalisation_opci o
JOIN dbo.v_controle_rationalisation c ON c.entite = o.entite AND c.arrete = o.arrete
JOIN dbo.ref_arrete r ON r.entite = o.entite AND r.arrete = o.arrete
-- 06/09/2026 : le premier arrete de l'entite n'a pas de comparatif, sa rationalisation
-- part de zero ; il ne se montre pas au client (script 148, arretes 2022 a 2024 vises).
WHERE r.porte_balance = 1 AND o.arrete_precedent IS NOT NULL;

GO

