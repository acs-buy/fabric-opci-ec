-- C44 : une reponse dont la forme ne correspond pas au type de la
-- question. Une question de choix repondue par un oui, ou une question
-- binaire repondue par un texte, est une reponse qui ne se lit pas.
-- ATTENDU zero.
CREATE   VIEW dbo.v_controle_reponse_forme_discordante AS
SELECT fq.cote, q.reference, q.type_reponse, fq.reponse, fq.reponse_valeur
FROM dbo.feuille_question fq
JOIN dbo.ref_question q ON q.id = fq.question_id
WHERE (fq.reponse IS NOT NULL OR fq.reponse_valeur IS NOT NULL)
  AND ((q.type_reponse IN ('OUI_NON', 'OUI_NON_NA') AND fq.reponse IS NULL)
    OR (q.type_reponse NOT IN ('OUI_NON', 'OUI_NON_NA')
        AND fq.reponse_valeur IS NULL));

GO

