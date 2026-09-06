
-- --- depuis 63_SQL/107_anr_filiale_detail.sql : v_anr_filiale --------------------
-- =====================================================================
-- O8 : L'ACTIF NET REEVALUE D'UNE FILIALE, COMPTE PAR COMPTE, ET LES
-- DEUX DEFINITIONS QUI DIVERGENT.
--
-- CE QUE LE POINT DEMANDAIT. La vue v_anr_filiale_detail pour l'ecran
-- E3-F1, et « 1 seule definition de l'actif net d'une filiale entre les
-- scripts 42 corrige par le 71 et 46 ».
--
-- CE QUE J'AI TROUVE, ET POURQUOI JE NE LES FUSIONNE PAS. Trois
-- definitions existent dans le depot, dont une morte : celle du script
-- 42 est ecrasee par celle du 71, qui vient apres dans la sequence. Les
-- 2 vivantes ne mesurent PAS la meme chose :
--   dbo.v_anr_filiale, script 71, lit les differences d'estimation de
--   dbo.v_valeur_actuelle_actif : la difference THEORIQUE, ecart entre
--   la valeur actuelle retenue et la valeur comptable, rattachee a
--   l'entite qui DETIENT l'actif ;
--   dbo.v_anr_entite, script 46, lit les ecritures des comptes 27x des
--   lots derivables : la difference COMPTABILISEE, rattachee a l'entite
--   du LOT.
-- Mesure du 04/09/2026 : 26 lignes sur 28 divergent, jusqu'a 158 000,00
-- d'ecart sur OMEGA-SCI-9 au 31/12/2024. Les fusionner effacerait cet
-- ecart, qui dit ce qui reste a comptabiliser ou ce qui l'a ete en trop.
-- La vue de detail les expose donc COTE A COTE, et un controle nomme
-- l'ecart.
--
-- LA CLASSE 19, VERIFIEE SUR PIECE LE 04/09/2026. Le plan de l'article
-- 411-3 porte « 19 - Regularisations », avec les comptes 191
-- regularisations du report a nouveau, 192 du resultat de l'exercice
-- clos, 193 des plus-values anterieures non distribuees et 198 des
-- acomptes verses. Le modele de bilan passif de l'article 321-6 ouvre
-- par « Capitaux propres (= actif net) ». L'inclusion du prefixe 19 dans
-- les capitaux propres est donc fondee : le script 46 l'inclut, le 71
-- l'omet, et ce script aligne le 71. Aucun compte 19 n'est mouvemente
-- dans le jeu, mesure : l'alignement est donc sans effet chiffre
-- aujourd'hui, et il evite une divergence a la premiere regularisation.
-- A executer contre la BASE SQL Fabric DossierOPCI.
-- =====================================================================

-- --- 1 : l'alignement du script 71 sur la classe 19 -----------------
CREATE   VIEW dbo.v_anr_filiale AS
WITH capitaux AS (
    SELECT l.entite, l.arrete,
           SUM(e.credit - e.debit) AS capitaux_propres_comptables
    FROM dbo.v_ecriture_normalisee e
    JOIN dbo.lot_ecritures l ON l.id = e.lot_id
    WHERE l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
      AND l.famille <> 'DERIVABLE'
      -- Le prefixe 19 entre dans les capitaux propres : plan de
      -- l'article 411-3, « 19 - Regularisations », et modele de bilan
      -- passif de l'article 321-6, « Capitaux propres (= actif net) ».
      AND (e.compte_num LIKE '10%' OR e.compte_num LIKE '11%'
        OR e.compte_num LIKE '12%' OR e.compte_num LIKE '13%'
        OR e.compte_num LIKE '14%' OR e.compte_num LIKE '19%')
    GROUP BY l.entite, l.arrete
),
ecarts AS (
    SELECT v.entite, v.arrete,
           SUM(v.difference_estimation) AS differences_d_estimation
    FROM dbo.v_valeur_actuelle_actif v
    GROUP BY v.entite, v.arrete
),
perimetre AS (
    SELECT entite, arrete FROM capitaux
    UNION
    SELECT entite, arrete FROM ecarts
)
SELECT p.entite, p.arrete,
       CAST(COALESCE(c.capitaux_propres_comptables, 0) AS DECIMAL (19,2))
           AS capitaux_propres_comptables,
       CAST(COALESCE(d.differences_d_estimation, 0) AS DECIMAL (19,2))
           AS differences_d_estimation,
       CAST(COALESCE(c.capitaux_propres_comptables, 0)
          + COALESCE(d.differences_d_estimation, 0) AS DECIMAL (19,2))
           AS actif_net_reevalue
FROM perimetre p
LEFT JOIN capitaux c ON c.entite = p.entite AND c.arrete = p.arrete
LEFT JOIN ecarts d ON d.entite = p.entite AND d.arrete = p.arrete;

GO

