
-- --- depuis 63_SQL/94_vues_intragroupe.sql : v_controle_symetrie_intragroupe -----
-- --- 6 : le controle de symetrie, l'invariant du lot ---------------
-- Un interet intragroupe est une charge chez l'emprunteur et un produit
-- chez le preteur, pour le meme montant et le meme arrete. Si les 2 ne
-- concordent pas, le groupe porte un profit ou une perte qui n'existe pas.
CREATE   VIEW dbo.v_controle_symetrie_intragroupe AS
WITH charge AS (
    SELECT l.entite, l.arrete, e.piece_ref AS reference,
           CAST(SUM(e.debit - e.credit) AS DECIMAL (19,2)) AS montant
    FROM dbo.v_ecriture_normalisee e JOIN dbo.lot_ecritures l ON l.id = e.lot_id
    WHERE e.compte_num IN ('623', '608') AND e.piece_ref LIKE 'EI-%'
      AND l.famille = 'IMPORTEE'
    GROUP BY l.entite, l.arrete, e.piece_ref
),
produit AS (
    SELECT l.entite, l.arrete, e.piece_ref AS reference,
           CAST(SUM(e.credit - e.debit) AS DECIMAL (19,2)) AS montant
    FROM dbo.v_ecriture_normalisee e JOIN dbo.lot_ecritures l ON l.id = e.lot_id
    WHERE e.compte_num IN ('724', '708') AND e.piece_ref LIKE 'EI-%'
      AND l.famille = 'IMPORTEE'
    GROUP BY l.entite, l.arrete, e.piece_ref
)
SELECT COALESCE(c.reference, p.reference)                  AS reference,
       COALESCE(c.arrete, p.arrete)                        AS arrete,
       c.entite                                            AS entite_emprunt,
       p.entite                                            AS entite_preteuse,
       COALESCE(c.montant, 0)                              AS charge,
       COALESCE(p.montant, 0)                              AS produit,
       CAST(COALESCE(c.montant, 0) - COALESCE(p.montant, 0)
            AS DECIMAL (19,2))                             AS ecart
FROM charge c
FULL OUTER JOIN produit p ON p.reference = c.reference AND p.arrete = c.arrete
WHERE COALESCE(c.montant, 0) <> COALESCE(p.montant, 0);

GO

