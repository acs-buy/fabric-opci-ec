
CREATE   VIEW dbo.v_ecran_c11_questions AS
SELECT ISNULL(CONVERT(nvarchar(200), t.cote), N'') + N'|'
     + ISNULL(CONVERT(nvarchar(200), t.question_id), N'') AS cle_ecran,
       t.*
FROM dbo.feuille_question t
WHERE EXISTS (SELECT 1 FROM dbo.feuille_travail f
              JOIN dbo.v_mon_perimetre p ON p.entite = f.entite AND p.arrete = f.arrete
              WHERE f.cote = t.cote);

GO

