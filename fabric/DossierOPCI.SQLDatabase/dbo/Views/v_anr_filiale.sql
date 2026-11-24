
-- --- v_anr_filiale ---
-- =====================================================================
-- L'ACTIF NET REEVALUE D'UNE FILIALE, COMPTE PAR COMPTE, ET LES
-- DEUX DEFINITIONS QUI DIVERGENT.
--
-- CE QUI ETAIT DEMANDE. La vue v_anr_filiale_detail pour l'ecran
-- du detail par filiale, et une seule definition de l'actif net d'une filiale
-- entre v_anr_filiale, dans sa version corrigee, et v_anr_entite.
--
-- CE QUE J'AI TROUVE, ET POURQUOI JE NE LES FUSIONNE PAS. Trois
-- definitions existaient dans la sequence d'installation, dont une morte : la
-- 1re version de v_anr_filiale, ecrasee par la 2e, qui vient apres. Les
-- 2 vivantes ne mesurent PAS la meme chose :
--   dbo.v_anr_filiale lit les differences d'estimation de
--   dbo.v_valeur_actuelle_actif : la difference THEORIQUE, ecart entre
--   la valeur actuelle retenue et la valeur comptable, rattachee a
--   l'entite qui DETIENT l'actif ;
--   dbo.v_anr_entite lit les ecritures des comptes 27x des
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
-- les capitaux propres est donc fondee : v_anr_entite l'inclut, v_anr_filiale
-- l'omettait, et cette version l'y aligne. Aucun compte 19 n'est mouvemente
-- dans le jeu, mesure : l'alignement est donc sans effet chiffre
-- aujourd'hui, et il evite une divergence a la premiere regularisation.
-- A executer contre la BASE SQL Fabric DossierOPCI.
-- =====================================================================

-- --- 1 : l'alignement de v_anr_filiale sur la classe 19 ------------
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

