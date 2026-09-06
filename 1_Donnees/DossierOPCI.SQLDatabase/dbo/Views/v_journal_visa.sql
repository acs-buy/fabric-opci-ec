
-- --- E4 : le journal du visa, refait ---------------------------
-- Trois corrections. Il unissait TOUT dbo.journal_refus, y compris les
-- refus d'import ou de validation de brouillon, qui ne sont pas des
-- refus de visa. Le proposant etait nul sur les refus. Et le cycle
-- s'affichait en code, sans libelle ni ordre.
CREATE   VIEW dbo.v_journal_visa AS
SELECT v.entite, v.arrete, v.cycle,
       COALESCE(c.libelle, 'Arrete')                  AS cycle_libelle,
       COALESCE(c.ordre, 99)                          AS cycle_ordre,
       v.decide_le                                    AS horodatage,
       'DECISION'                                     AS genre,
       CAST(v.nature AS VARCHAR (30))                 AS nature,
       v.objet_ref, v.decision                        AS issue,
       v.decide_par                                   AS auteur,
       v.propose_par,
       CAST(v.motif AS NVARCHAR (2000))               AS message
FROM dbo.visa v
LEFT JOIN dbo.ref_cycle c ON c.code = v.cycle
UNION ALL
SELECT r.entite, r.arrete, f.cycle,
       COALESCE(fc.libelle, 'Arrete'), COALESCE(fc.ordre, 99),
       r.refuse_le, 'REFUS',
       CAST(r.procedure_nom AS VARCHAR (30)),
       CAST(r.cote AS VARCHAR (30)), 'REFUSE',
       r.refuse_pour,
       -- Le proposant est resolu depuis la source, la nature se deduisant
       -- du nom de la procedure : un refus sans proposant ne dit pas a
       -- qui l'objet appartient.
       dbo.fn_proposant(
           CASE r.procedure_nom
                WHEN 'pr_viser_lot' THEN 'LOT'
                WHEN 'pr_viser_conclusion' THEN 'CONCLUSION'
                WHEN 'pr_viser_derogation' THEN 'DEROGATION'
                WHEN 'pr_viser_evaluation' THEN 'EVALUATION'
                WHEN 'pr_viser_ecart' THEN 'EVALUATION'
                WHEN 'pr_publier_vl' THEN 'PUBLICATION'
                WHEN 'pr_viser_obligation_distribution' THEN 'OBLIGATION'
           END,
           COALESCE(r.cote, r.entite + '|' + r.arrete)),
       r.message
FROM dbo.journal_refus r
LEFT JOIN dbo.feuille_travail f ON f.cote = r.cote
LEFT JOIN dbo.ref_cycle fc ON fc.code = f.cycle
-- Seules les procedures de visa : un refus d'import n'est pas un refus de
-- supervision, et il a son propre journal a l'ecran des imports.
WHERE r.procedure_nom IN ('pr_viser_lot', 'pr_viser_conclusion',
                          'pr_viser_derogation', 'pr_viser_evaluation',
                          'pr_viser_ecart', 'pr_publier_vl',
                          'pr_viser_obligation_distribution');

GO

