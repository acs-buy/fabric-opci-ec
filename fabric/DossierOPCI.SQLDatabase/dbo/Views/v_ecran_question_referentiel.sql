
CREATE   VIEW dbo.v_ecran_question_referentiel AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[question_id], 121), N'') AS cle_ecran, v.*
FROM dbo.v_question_referentiel v;

GO

