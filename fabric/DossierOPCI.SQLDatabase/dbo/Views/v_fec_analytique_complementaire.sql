

-- BLOC 3 : v_fec_analytique_complementaire, les mêmes 22 colonnes que le bloc 1, sur les seules écritures d'ajustement
--
-- Périmètre : lots de famille DECIDEE et DERIVABLE, aux mêmes 3 statuts.
-- La famille est lue sur le lot et non sur l'écriture.
CREATE   VIEW dbo.v_fec_analytique_complementaire AS
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
    ax.entite             AS entite,
    ax.code_actif         AS code_actif,
    ax.code_projet        AS code_projet,
    ax.code_lot           AS code_lot,
    e.lot_id              AS lot_id
FROM dbo.ecriture e
JOIN dbo.lot_ecritures l ON l.id = e.lot_id
LEFT JOIN dbo.ecriture_axe ax ON ax.ecriture_id = e.id
WHERE l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
  AND l.famille IN ('DECIDEE', 'DERIVABLE');

GO

