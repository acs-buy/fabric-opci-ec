
-- C47 : un modele dont le compte n'appartient pas au plan de l'entite
-- qui repondrait a la question. La cle etrangere garantit que le compte
-- est au referentiel ; elle ne garantit pas qu'il est au plan de
-- l'OPCI. Les comptes de ces modeles viennent tous de l'article 411-3.
CREATE   VIEW dbo.v_modele_compte_hors_plan_opci AS
SELECT q.reference, m.ordre, m.compte_num, c.libelle
FROM dbo.modele_ecriture m
JOIN dbo.ref_question q ON q.id = m.question_id
LEFT JOIN dbo.ref_compte c ON c.compte = m.compte_num
WHERE c.compte IS NULL;

GO

