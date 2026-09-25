
CREATE   VIEW dbo.v_a_viser_lot AS
SELECT l.entite, l.arrete,
       COALESCE(f.cycle, l.portee)                    AS cycle,
       'LOT'                                          AS nature,
       CAST(l.id AS VARCHAR (30))                     AS objet_ref,
       l.id                                           AS objet_id,
       CAST(N'Lot ' + CAST(l.id AS NVARCHAR (20)) + N', famille '
            + l.famille + N', portee ' + l.portee AS NVARCHAR (300))
                                                      AS libelle,
       l.cree_par                                     AS propose_par,
       l.cree_le                                      AS propose_le,
       (SELECT COUNT(*) FROM dbo.ecriture e WHERE e.lot_id = l.id)
                                                      AS lignes,
       (SELECT CAST(SUM(e.debit) AS DECIMAL (19,2)) FROM dbo.ecriture e
        WHERE e.lot_id = l.id)                        AS montant,
       l.statut                                       AS etat,
       -- 07/09/2026 : le motif de refus ecrit par la procedure du bouton (138), lu a l'ecran.
       l.message_ecran
FROM dbo.lot_ecritures l
LEFT JOIN dbo.feuille_travail f ON f.cote = l.feuille_cote
WHERE l.statut = 'PROPOSE';

GO

