
CREATE   VIEW dbo.v_mes_refus AS
SELECT TOP 200 j.id, j.procedure_nom, j.entite, j.arrete, j.cote,
       j.question_reference,
       q.enonce                          AS question,
       j.message,
       -- Le geste explicite quand la procedure l'a ecrit ; a defaut, la
       -- derniere phrase du message, qui porte l'action par convention
       -- de redaction des refus.
       COALESCE(j.geste,
                LTRIM(RIGHT(j.message,
                            CHARINDEX('.', REVERSE(LEFT(j.message,
                                LEN(j.message) - 1))))))  AS geste,
       j.refuse_pour, j.refuse_le
FROM dbo.journal_refus j
LEFT JOIN dbo.ref_question q ON q.reference = j.question_reference
ORDER BY j.refuse_le DESC;

GO

