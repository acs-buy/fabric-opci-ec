
-- --- 5 : la vue du modele, lue par l'ecran a l'ouverture de la saisie ---
-- ATTENDU : une question sans modele rend zero ligne, l'ecran ouvre alors
-- une saisie libre.
CREATE   VIEW dbo.v_modele_ecriture AS
SELECT m.question_id, q.reference AS question, m.ordre, m.compte_num,
       COALESCE(c.libelle, m.compte_num) AS compte_libelle,
       m.sens, m.libelle, m.source,
       CAST(0 AS DECIMAL (19,2)) AS montant
FROM dbo.modele_ecriture m
INNER JOIN dbo.ref_question q ON q.id = m.question_id
LEFT JOIN dbo.ref_compte c ON c.compte = m.compte_num;

GO

