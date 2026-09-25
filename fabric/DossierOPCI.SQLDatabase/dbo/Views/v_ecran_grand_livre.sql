CREATE VIEW dbo.v_ecran_grand_livre AS
SELECT
    e.cle_ecran, e.entite, e.arrete,
    e.compte, e.compte_libelle, e.classe, e.compte_auxiliaire,
    e.date_ecriture, e.journal_code, e.piece_ref, e.libelle,
    e.debit, e.credit, e.solde,
    nature_ecriture = CAST(CASE e.lot_famille
                             WHEN 'IMPORTEE' THEN N'Comptabilité du client'
                             ELSE N'Écriture de révision' END AS nvarchar(40)),
    etat_ecriture   = CAST(CASE WHEN e.lot_statut = 'VALIDE' THEN N'Approuvée'
                                ELSE N'Proposée, sans visa' END AS nvarchar(40)),
    -- 1 quand la ligne entre dans le definitif, 0 quand elle attend un visa. Un tri ou un total
    -- se pose sur ce drapeau, un libelle ne s'additionne pas.
    est_approuvee   = CAST(CASE WHEN e.lot_statut = 'VALIDE' THEN 1 ELSE 0 END AS bit),
    e.lot_id, e.lot_famille, e.lot_statut, e.lot_perime,
    e.origine, e.feuille_cote, e.question_reference, e.code_actif, e.compte_origine
FROM dbo.v_ecran_ecritures_du_compte e;

GO

