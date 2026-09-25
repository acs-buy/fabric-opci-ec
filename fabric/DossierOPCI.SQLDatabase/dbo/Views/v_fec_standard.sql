

-- BLOC 2 : v_fec_standard, les 18 champs de l'article et rien d'autre, hors la clef de portée
--
-- Périmètre : identique au bloc 1.
CREATE   VIEW dbo.v_fec_standard AS
SELECT
    e.journal_code        AS JournalCode,
    e.journal_lib         AS JournalLib,
    e.ecriture_num        AS EcritureNum,
    e.ecriture_date       AS EcritureDate,
    COALESCE(e.compte_origine,
             (SELECT MAX(r.compte_entite)
                FROM dbo.ref_compte_entite r
               WHERE r.entite = l.entite
                 AND r.compte_modele = e.compte_num
              HAVING COUNT(*) = 1)) AS CompteNum,
    e.compte_lib          AS CompteLib,
    e.comp_aux_num        AS CompAuxNum,
    e.comp_aux_lib        AS CompAuxLib,
    e.piece_ref           AS PieceRef,
    e.piece_date          AS PieceDate,
    e.ecriture_lib        AS EcritureLib,
    e.debit               AS Debit,
    e.credit              AS Credit,
    e.ecriture_let        AS EcritureLet,
    e.date_let            AS DateLet,
    e.valid_date          AS ValidDate,
    e.montant_devise      AS Montantdevise,
    e.id_devise           AS Idevise,
    e.lot_id              AS lot_id
FROM dbo.ecriture e
JOIN dbo.lot_ecritures l ON l.id = e.lot_id
WHERE l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE');

GO

