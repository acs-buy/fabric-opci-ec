
-- un cycle est au programme de l'arrete s'il porte au moins une question active
CREATE   FUNCTION dbo.fn_cycle_au_programme (@entite VARCHAR (20), @arrete VARCHAR (20), @cycle VARCHAR (10))
RETURNS BIT
AS
BEGIN
    RETURN CASE WHEN EXISTS (SELECT 1 FROM dbo.programme_travail p JOIN dbo.programme_question pq ON pq.programme_id = p.id AND pq.actif = 1
                             JOIN dbo.ref_question q ON q.id = pq.question_id
                             WHERE p.entite = @entite AND p.arrete = @arrete AND q.cycle = @cycle) THEN 1 ELSE 0 END;
END;

GO

