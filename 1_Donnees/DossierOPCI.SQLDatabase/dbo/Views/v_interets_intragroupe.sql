-- =====================================================================
-- LES 4 VUES DES INTERETS INTRAGROUPE ET DES CHARGES DE FONCTIONNEMENT,
-- extraites du script 91 le 04/09/2026.
--
-- POURQUOI CETTE EXTRACTION. Le script 91 est joue AVANT le 66 et le 67,
-- qui ont besoin de ses 3 subdivisions de comptes et de sa table
-- d'emprunts pour batir les balances. Or ces 4 vues lisent dbo.ref_arrete
-- et les ecritures, que les scripts 72 et 67 creent apres lui : le rejeu
-- a rendu « Invalid object name 'dbo.ref_arrete' » au 1er script de la
-- reprise. C'est le quatrieme defaut d'ordre de la serie, et la cause est
-- toujours la meme : un script qui apprend a lire une table doit etre
-- verifie contre la position de la creation de cette table.
-- A executer contre la BASE SQL Fabric DossierOPCI.
-- =====================================================================

-- --- 5 : les interets a comptabiliser, par emprunt et par arrete ----
-- Les interets courus de l'exercice, au prorata du temps ecoule depuis le
-- versement lorsque celui-ci tombe dans l'exercice. Le calcul est
-- deterministe : c'est la condition de la concordance mesuree.
CREATE   VIEW dbo.v_interets_intragroupe AS
SELECT e.id AS emprunt_id, e.reference, e.entite_preteuse, e.entite_emprunt,
       e.objet, e.code_actif, e.capital_restant, e.taux_annuel,
       r.arrete, r.date_arrete, r.exercice,
       -- Le nombre de jours courus dans l'exercice, borne au versement.
       CASE WHEN e.date_versement > DATEADD(YEAR, -1, r.date_arrete)
            THEN DATEDIFF(DAY, e.date_versement, r.date_arrete)
            ELSE 360 END                                  AS jours_courus,
       CAST(e.capital_restant * e.taux_annuel / 100.0
            * CASE WHEN e.date_versement > DATEADD(YEAR, -1, r.date_arrete)
                   THEN DATEDIFF(DAY, e.date_versement, r.date_arrete) / 360.0
                   ELSE 1.0 END AS DECIMAL (19,2))         AS interets,
       c.compte_charge, c.compte_produit, c.resultat, c.reference AS fondement
FROM dbo.emprunt_intragroupe e
-- FILTRE CORRIGE le 04/09/2026. La vue filtrait sur
-- nature_technique = 'MISSION', or UN SEUL arrete sur 31 porte cette
-- nature dans le jeu, celui de OMEGA-OPCI au 31/12/2025 : les 12 filiales
-- n'en ont aucun, et la vue rendait 0 ligne. Son zero etait un FAUX ZERO,
-- le controle ne portant sur rien. Le filtre retenu est porte_balance = 1,
-- qui designe les arretes reellement comptabilises.
JOIN dbo.ref_arrete r ON r.entite = e.entite_emprunt AND r.porte_balance = 1
                     AND r.date_arrete >= e.date_versement
JOIN dbo.ref_classement_interet c ON c.objet = e.objet;

GO

