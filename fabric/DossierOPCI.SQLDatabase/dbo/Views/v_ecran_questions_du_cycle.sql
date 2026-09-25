CREATE   VIEW dbo.v_ecran_questions_du_cycle AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[feuille_question_id], 121), N'') AS cle_ecran,
       v.*,
       CASE WHEN v.[cycle] IS NULL THEN NULL ELSE
            ISNULL(CONVERT(NVARCHAR (200), v.[entite], 121), N'') + N'|'
          + ISNULL(CONVERT(NVARCHAR (200), v.[arrete], 121), N'') + N'|'
          + ISNULL(CONVERT(NVARCHAR (200), v.[cycle], 121), N'')
       END AS cle_cycle
FROM dbo.v_questions_du_cycle v;

GO

