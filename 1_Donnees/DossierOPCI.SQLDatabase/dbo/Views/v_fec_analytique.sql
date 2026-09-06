-- =====================================================================
-- L'export du fichier des écritures comptables : 3 vues de projection et 2 contrôles de refus
-- À exécuter bloc par bloc, après 63_SQL/01_schema.sql, 63_SQL/09_fec_18_champs.sql
-- et 63_SQL/10_transit_et_rattachement.sql
-- Les 18 champs sont ceux de l'article A47 A-1 du livre des procédures fiscales, section VII
-- =====================================================================


-- BLOC 1 : v_fec_analytique, les 18 champs de l'article, les 4 axes analytiques, la clef de portée
--
-- Périmètre : lots aux statuts VALIDE, EXPORTE et PUBLIE, sans filtre de famille.
CREATE   VIEW dbo.v_fec_analytique AS
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
WHERE l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE');

GO

