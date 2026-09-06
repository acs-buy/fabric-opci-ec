
-- --- E5 : les lots du cycle, tous etats -----------------------
-- v_a_viser_lot fait disparaitre la ligne des que le geste est pose : le
-- chef de mission n'a aucun retour visible sur ce qu'il vient de decider.
-- Cette vue rend les lots du cycle quel que soit leur etat, avec le
-- dernier message de visa ou de refus.
CREATE   VIEW dbo.v_lots_du_cycle AS
SELECT l.id AS lot_id, l.entite, l.arrete, l.famille, l.portee, l.statut,
       COALESCE(f.cycle, l.portee)                    AS cycle,
       COALESCE(c.libelle, 'Arrete')                  AS cycle_libelle,
       COALESCE(c.ordre, 99)                          AS cycle_ordre,
       l.cree_par, l.cree_le, l.statut_par, l.statut_le,
       l.perime_le,
       CAST(CASE WHEN l.perime_le IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS perime,
       l.perime_motif,
       (SELECT COUNT(*) FROM dbo.ecriture e WHERE e.lot_id = l.id) AS lignes,
       (SELECT CAST(SUM(e.debit) AS DECIMAL (19,2)) FROM dbo.ecriture e
        WHERE e.lot_id = l.id)                        AS montant,
       d.decision                                     AS derniere_decision,
       d.decide_par                                   AS dernier_decideur,
       d.decide_le                                    AS derniere_decision_le,
       -- Le dernier message porte, dans l'ordre : le motif du visa, le
       -- motif du refus, le motif du lot.
       COALESCE(d.motif, refus.message, l.motif)      AS dernier_message,
       CASE WHEN d.decision IS NOT NULL THEN 'DECISION'
            WHEN refus.message IS NOT NULL THEN 'REFUS'
            ELSE NULL END                             AS genre_dernier_message
FROM dbo.lot_ecritures l
LEFT JOIN dbo.feuille_travail f ON f.cote = l.feuille_cote
LEFT JOIN dbo.ref_cycle c ON c.code = f.cycle
LEFT JOIN dbo.v_derniere_decision d ON d.nature = 'LOT'
                                   AND d.objet_ref = CAST(l.id AS VARCHAR (30))
OUTER APPLY (
    SELECT TOP (1) r.message FROM dbo.journal_refus r
    WHERE r.procedure_nom IN ('pr_viser_lot', 'pr_annuler_lot')
      AND r.cote = CAST(l.id AS VARCHAR (30))
    ORDER BY r.refuse_le DESC
) AS refus;

GO

