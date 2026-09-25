
-- --- 6. choisir le programme, l'ajuster, verifier la couverture ------------------------------------
CREATE   PROCEDURE dbo.pr_choisir_programme
    @entite  VARCHAR (20),
    @arrete  VARCHAR (20),
    @type    VARCHAR (10),          -- ALLEGE, CLASSIQUE, ETENDU
    @par     NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF @type NOT IN ('ALLEGE', 'CLASSIQUE', 'ETENDU')
        THROW 50301, N'Le programme est ALLEGE, CLASSIQUE ou ETENDU.', 1;
    DECLARE @type_arrete VARCHAR (14) = (SELECT type_arrete FROM dbo.arrete_mission WHERE entite = @entite AND arrete = @arrete);
    IF @type_arrete IS NULL
        THROW 50302, N'Le programme se choisit sur un arrêté ouvert ; celui-ci ne l''est pas.', 1;
    IF dbo.fn_dossier_verrouille(@entite, @arrete) = 1
        THROW 50303, N'Le dossier de cet arrêté est visé et verrouillé ; le déverrouiller avant de modifier le programme.', 1;

    DECLARE @niveau TINYINT = CASE @type WHEN 'ALLEGE' THEN 1 WHEN 'CLASSIQUE' THEN 2 ELSE 3 END;
    DECLARE @id INT, @ajoutees INT = 0, @retirees INT = 0;
    BEGIN TRY
    BEGIN TRANSACTION;
    SELECT @id = id FROM dbo.programme_travail WHERE entite = @entite AND arrete = @arrete;
    IF @id IS NULL
    BEGIN
        INSERT INTO dbo.programme_travail (entite, arrete, type_programme, choisi_par) VALUES (@entite, @arrete, @type, @par);
        SET @id = SCOPE_IDENTITY();
    END
    ELSE
        UPDATE dbo.programme_travail SET type_programme = @type, choisi_par = @par, choisi_le = SYSUTCDATETIME() WHERE id = @id;
    INSERT INTO dbo.programme_journal (programme_id, geste, detail, par) VALUES (@id, 'CHOIX', @type, @par);

    -- la selection du type : questions de cycle, non ecartees, applicables a l'arrete, de niveau <= celui du type
    DECLARE @sel TABLE (question_id INT PRIMARY KEY, cycle VARCHAR (10));
    INSERT INTO @sel
    SELECT q.id, q.cycle FROM dbo.ref_question q
    WHERE q.cycle IS NOT NULL AND q.statut <> 'ECARTEE'
      AND (q.applicabilite = 'LES_DEUX' OR (q.applicabilite = 'ARRETE_CLOTURE' AND @type_arrete = 'ANNUEL')
           OR (q.applicabilite = 'ARRETE_VL' AND @type_arrete <> 'ANNUEL'))
      AND (q.niveau_programme IS NULL OR q.niveau_programme <= @niveau);

    -- entrent : les selectionnees absentes ou inactives d'origine TYPE
    UPDATE pq SET actif = 1, modifie_par = @par, modifie_le = SYSUTCDATETIME()
    FROM dbo.programme_question pq JOIN @sel s ON s.question_id = pq.question_id
    WHERE pq.programme_id = @id AND pq.actif = 0;
    SET @ajoutees = @@ROWCOUNT;
    INSERT INTO dbo.programme_question (programme_id, question_id, actif, origine, modifie_par)
    SELECT @id, s.question_id, 1, 'TYPE', @par FROM @sel s
    WHERE NOT EXISTS (SELECT 1 FROM dbo.programme_question pq WHERE pq.programme_id = @id AND pq.question_id = s.question_id);
    SET @ajoutees += @@ROWCOUNT;
    -- sortent : les actives d'origine TYPE que le nouveau type ne selectionne plus ; les AJOUT du reviseur restent
    UPDATE pq SET actif = 0, modifie_par = @par, modifie_le = SYSUTCDATETIME()
    FROM dbo.programme_question pq
    WHERE pq.programme_id = @id AND pq.actif = 1 AND pq.origine = 'TYPE'
      AND NOT EXISTS (SELECT 1 FROM @sel s WHERE s.question_id = pq.question_id);
    SET @retirees = @@ROWCOUNT;

    EXEC dbo.pr_instancier_programme @id, @par;
    COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    DECLARE @actives INT = (SELECT COUNT(*) FROM dbo.programme_question WHERE programme_id = @id AND actif = 1);
    DECLARE @cycles INT = (SELECT COUNT(DISTINCT q.cycle) FROM dbo.programme_question pq JOIN dbo.ref_question q ON q.id = pq.question_id
                           WHERE pq.programme_id = @id AND pq.actif = 1);
    SELECT @id AS programme_id, @actives AS questions, @cycles AS cycles,
           N'Programme ' + LOWER(@type) + N' : ' + CAST(@actives AS NVARCHAR (10)) + N' questions sur ' + CAST(@cycles AS NVARCHAR (10))
         + N' cycles, ' + CAST(@ajoutees AS NVARCHAR (10)) + N' entrée(s), ' + CAST(@retirees AS NVARCHAR (10)) + N' sortie(s).'
         + CASE WHEN NOT EXISTS (SELECT 1 FROM dbo.ref_question WHERE niveau_programme IS NOT NULL)
                THEN N' Les 3 types sélectionnent encore les mêmes questions : la profondeur des questions se renseigne aux Référentiels.'
                ELSE N'' END AS message;
END;

GO

