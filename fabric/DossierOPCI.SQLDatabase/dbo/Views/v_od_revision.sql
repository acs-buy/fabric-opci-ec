
CREATE   VIEW dbo.v_od_revision AS
SELECT b.entite, b.arrete, f.cycle, b.feuille_cote AS cote, q.reference, 'BROUILLON' AS etat, NULL AS lot_id,
       b.journal_code, b.compte_num, b.libelle, b.debit, b.credit, b.reference AS piece_ref, b.code_actif, b.saisi_par AS par, b.saisi_le AS le
FROM dbo.ecriture_brouillon b
JOIN dbo.feuille_travail f ON f.cote = b.feuille_cote
LEFT JOIN dbo.ref_question q ON q.id = b.question_id
UNION ALL
SELECT l.entite, l.arrete, f.cycle, l.feuille_cote, q.reference, l.statut, l.id,
       e.journal_code, e.compte_num, e.ecriture_lib, e.debit, e.credit, e.piece_ref,
       (SELECT TOP 1 a.code_actif FROM dbo.ecriture_axe a WHERE a.ecriture_id = e.id), l.cree_par, l.cree_le
FROM dbo.lot_ecritures l
JOIN dbo.ecriture e ON e.lot_id = l.id
LEFT JOIN dbo.feuille_travail f ON f.cote = l.feuille_cote
LEFT JOIN dbo.ref_question q ON q.id = l.question_id
WHERE l.famille = 'DECIDEE';

GO

