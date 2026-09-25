

-- ---------------------------------------------------------------------
-- BLOC 4 : la vue de dérive de la copie. SEULE DANS SON LOT.
-- CREATE OR ALTER VIEW seule dans son lot (documentation de l'éditeur,
-- section Remarks de CREATE VIEW).
-- Rend toute écriture dont la copie de famille est absente ou diffère de
-- la famille de son lot, qui fait seule foi.
-- ATTENDU : 0 ligne sur une base où le bloc 2 vient de s'exécuter.
-- ---------------------------------------------------------------------
CREATE   VIEW dbo.v_ecriture_famille_discordante AS
SELECT e.id                 AS ecriture_id,
       e.lot_id             AS lot_id,
       e.journal_code       AS journal_code,
       e.famille            AS famille_sur_ecriture,
       l.famille            AS famille_du_lot,
       l.arrete             AS arrete,
       l.entite             AS entite
FROM dbo.ecriture e
JOIN dbo.lot_ecritures l ON l.id = e.lot_id
WHERE e.famille IS NULL
   OR e.famille <> l.famille;

GO

