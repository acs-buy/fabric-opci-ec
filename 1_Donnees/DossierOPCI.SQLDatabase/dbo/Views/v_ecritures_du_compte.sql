
-- --- 2 : O9, les ecritures d'un compte sur l'arrete -----------------
-- L'origine se lit de ce que l'ecriture porte : une question de feuille,
-- un actif, ou ni l'un ni l'autre pour une ecriture importee.
CREATE   VIEW dbo.v_ecritures_du_compte AS
SELECT e.id                                AS ecriture_id,
       l.entite, l.arrete,
       e.compte_num                        AS compte,
       COALESCE(c.libelle_complet, c.libelle) AS compte_libelle,
       dbo.fn_classe_du_compte(e.compte_num)  AS classe,
       e.ecriture_date                     AS date_ecriture,
       e.journal_code, e.piece_ref,
       e.ecriture_lib                      AS libelle,
       e.debit, e.credit,
       e.debit - e.credit                  AS solde,
       l.id                                AS lot_id,
       l.famille                           AS lot_famille,
       l.statut                            AS lot_statut,
       l.portee                            AS lot_portee,
       CAST(CASE WHEN l.perime_le IS NOT NULL THEN 1 ELSE 0 END AS BIT)
                                           AS lot_perime,
       -- L'origine de l'ecriture. Elle ne se lit PAS de l'ecriture :
       -- dbo.ecriture ne porte ni question ni actif. La question est sur
       -- le LOT, depuis le script 56 ; l'actif est dans dbo.ecriture_axe,
       -- l'axe analytique du format d'ecriture.
       CASE WHEN q.reference IS NOT NULL THEN N'Question ' + q.reference
            WHEN ax.code_actif IS NOT NULL THEN N'Actif ' + ax.code_actif
            WHEN l.famille = 'IMPORTEE'   THEN N'Import de balance ou de FEC'
            ELSE N'non rattachee' END      AS origine,
       q.reference                         AS question_reference,
       l.feuille_cote,
       ax.code_actif,
       e.comp_aux_num                      AS compte_auxiliaire,
       e.compte_origine
FROM dbo.ecriture e
JOIN dbo.lot_ecritures l ON l.id = e.lot_id
LEFT JOIN dbo.ref_compte c ON c.compte = e.compte_num
LEFT JOIN dbo.ref_question q ON q.id = l.question_id
LEFT JOIN dbo.ecriture_axe ax ON ax.ecriture_id = e.id;

GO

