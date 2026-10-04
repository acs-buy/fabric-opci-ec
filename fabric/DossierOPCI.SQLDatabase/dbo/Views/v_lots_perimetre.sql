

-- 3. LES LOTS DU PERIMETRE : une ligne par lot et par vehicule au perimetre duquel l'entite du lot
-- appartient a l'arrete du lot. Toutes les colonnes de v_lots_du_cycle, sans recalcul, et le libelle du
-- segment, compose comme la maquette le compose. Aucun statut n'est filtre.
CREATE   VIEW dbo.v_lots_perimetre AS
SELECT p.vehicule,
       l.lot_id, l.entite, l.arrete, l.famille, l.portee, l.statut, l.cycle, l.cycle_libelle, l.cycle_ordre,
       l.cree_par, l.cree_le, l.statut_par, l.statut_le, l.perime_le, l.perime, l.perime_motif, l.lignes, l.montant,
       l.derniere_decision, l.dernier_decideur, l.derniere_decision_le, l.dernier_message, l.genre_dernier_message, l.message_ecran,
       CAST(N'Lot ' + CAST(l.lot_id AS NVARCHAR (12)) + N' · ' + l.entite + N' · ' + ISNULL(l.cycle, N'') AS NVARCHAR (80)) AS libelle_choix
FROM dbo.v_lots_du_cycle l
JOIN dbo.v_perimetre_vehicule p ON p.entite = l.entite AND p.arrete = l.arrete;

GO

