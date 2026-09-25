
-- C40 : une diligence des phases ACCEPT ou MAINTIEN sans aucun
-- fondement. Une question de mission sans texte qui la fonde n'est pas
-- une diligence. ATTENDU zero.
CREATE   VIEW dbo.v_controle_question_sans_fondement AS
SELECT DISTINCT reference, phase, LEFT(enonce, 70) AS enonce
FROM dbo.v_question_fondement
WHERE phase IN ('ACCEPT', 'MAINTIEN') AND source_fondement IS NULL;

GO

