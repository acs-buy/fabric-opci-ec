
-- Les questions actives du programme deviennent des lignes a repondre : une feuille par cycle,
-- cote Q-<cycle>-P<id>, et une ligne de feuille_question par question active.
CREATE   PROCEDURE dbo.pr_instancier_programme
    @programme_id INT,
    @par          NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @entite VARCHAR (20), @arrete VARCHAR (20);
    SELECT @entite = entite, @arrete = arrete FROM dbo.programme_travail WHERE id = @programme_id;

    INSERT INTO dbo.feuille_travail (cote, cycle, phase, arrete, entite, modele_code, origine, nom_fichier, chemin_coffre,
                                     empreinte_sha256, preparateur, prepare_le)
    SELECT 'Q-' + c.code + '-P' + CAST(@programme_id AS VARCHAR (10)), c.code, NULL, @arrete, @entite, NULL, 'HUMAINE',
           N'questions_' + c.code + N'_' + @entite + N'_' + @arrete + N'.xlsx',
           N'/Coffre/' + @entite + N'/' + @arrete + N'/questions/' + c.code + N'.xlsx',
           CONVERT(CHAR (64), HASHBYTES('SHA2_256', CONVERT(NVARCHAR (100), 'Q-' + c.code + '-P' + CAST(@programme_id AS VARCHAR (10)))), 2),
           @par, SYSUTCDATETIME()
    FROM dbo.ref_cycle c
    WHERE EXISTS (SELECT 1 FROM dbo.programme_question pq JOIN dbo.ref_question q ON q.id = pq.question_id
                  WHERE pq.programme_id = @programme_id AND pq.actif = 1 AND q.cycle = c.code)
      AND NOT EXISTS (SELECT 1 FROM dbo.feuille_travail f WHERE f.cote = 'Q-' + c.code + '-P' + CAST(@programme_id AS VARCHAR (10)));

    INSERT INTO dbo.feuille_question (cote, question_id)
    SELECT 'Q-' + q.cycle + '-P' + CAST(@programme_id AS VARCHAR (10)), q.id
    FROM dbo.programme_question pq JOIN dbo.ref_question q ON q.id = pq.question_id
    WHERE pq.programme_id = @programme_id AND pq.actif = 1
      AND NOT EXISTS (SELECT 1 FROM dbo.feuille_question fq
                      WHERE fq.cote = 'Q-' + q.cycle + '-P' + CAST(@programme_id AS VARCHAR (10)) AND fq.question_id = q.id);

    -- les questions sorties du programme quittent la liste si elles sont sans reponse
    DELETE fq FROM dbo.feuille_question fq
    JOIN dbo.ref_question q ON q.id = fq.question_id
    JOIN dbo.programme_question pq ON pq.question_id = q.id AND pq.programme_id = @programme_id AND pq.actif = 0
    WHERE fq.cote = 'Q-' + q.cycle + '-P' + CAST(@programme_id AS VARCHAR (10))
      AND fq.reponse IS NULL AND fq.reponse_valeur IS NULL;
END;

GO

