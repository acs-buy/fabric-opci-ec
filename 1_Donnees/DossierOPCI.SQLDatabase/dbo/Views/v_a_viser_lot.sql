-- =====================================================================
-- LOT F du plan fusionne, deuxieme partie : les vues de l'ecran
-- Supervision. Une vue homogene par nature d'objet a viser, la synthese
-- par cycle, et le journal des decisions et des refus.
--
-- LES 5 VUES « A VISER » PORTENT LES MEMES COLONNES, dans le meme ordre :
-- entite, arrete, cycle, nature, objet_ref, libelle, propose_par,
-- propose_le, lignes, montant, etat. L'ecran les empile donc sans les
-- traiter une par une, et une nature ajoutee plus tard n'oblige pas a
-- refaire l'ecran. Les colonnes qui n'ont pas de sens pour une nature
-- rendent NULL plutot qu'une valeur de remplissage : un montant a zero
-- sur une conclusion se lirait comme un montant nul, non comme une
-- absence de montant.
--
-- CE QUE « A VISER » VEUT DIRE, nature par nature :
--   LOT         statut PROPOSE
--   CONCLUSION  une conclusion posee, aucun visa VISE sur cette cote
--   DEROGATION  accordee, non levee, aucun visa VISE
--   ECART       etat PROPOSE dans dbo.evaluation_actif
--   PUBLICATION la valeur liquidative est calculable, rien n'est publie
--               et aucun lot n'est en attente de visa
-- A executer contre la BASE SQL Fabric DossierOPCI.
-- =====================================================================

-- --- 1 : les lots a viser --------------------------------------------
CREATE   VIEW dbo.v_a_viser_lot AS
SELECT l.entite, l.arrete,
       COALESCE(f.cycle, l.portee)                    AS cycle,
       'LOT'                                          AS nature,
       CAST(l.id AS VARCHAR (30))                     AS objet_ref,
       CAST(N'Lot ' + CAST(l.id AS NVARCHAR (20)) + N', famille '
            + l.famille + N', portee ' + l.portee AS NVARCHAR (300))
                                                      AS libelle,
       l.cree_par                                     AS propose_par,
       l.cree_le                                      AS propose_le,
       (SELECT COUNT(*) FROM dbo.ecriture e WHERE e.lot_id = l.id)
                                                      AS lignes,
       (SELECT CAST(SUM(e.debit) AS DECIMAL (19,2)) FROM dbo.ecriture e
        WHERE e.lot_id = l.id)                        AS montant,
       l.statut                                       AS etat
FROM dbo.lot_ecritures l
LEFT JOIN dbo.feuille_travail f ON f.cote = l.feuille_cote
WHERE l.statut = 'PROPOSE';

GO

