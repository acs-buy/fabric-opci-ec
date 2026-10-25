-- ecran 5, lot 1, script 324 (61_DEPLOIEMENT/generer_e5_324_questions.py) : genere, ne pas modifier a la main.
-- Objet n° 33 : « Ecarter la question ». Passe une question a ECARTEE (« écartée ») ; une question repondue s'ecarte
-- et ne se supprime pas. Associe seul, exige ici, la garde tr_ref_question_garde admettant aussi le reviseur. La
-- question se recoit par sa reference (segment « Question ») ou par son identifiant. Refus en francais : @par vide,
-- droit, question vide ou inconnue, question deja ecartee, motif de plus de 600 caracteres. Le motif, facultatif
-- comme au n° 14, s'ecrit dans le message de reussite quand il est saisi, ref_question n'ayant pas de colonne de motif
-- (point 9 de la decoupe) ; il n'est garde nulle part ailleurs (limite declaree).
CREATE   PROCEDURE dbo.pr_ecran_ecarter_question
    @question       NVARCHAR (400) = NULL,
    @motif          NVARCHAR (MAX) = NULL,
    @par            NVARCHAR (400) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @tc INT = @@TRANCOUNT, @journal_avant INT = ISNULL((SELECT MAX(id) FROM dbo.journal_refus), 0),
            @proc VARCHAR (60) = 'pr_ecran_ecarter_question', @e_num INT, @e_msg NVARCHAR (2048), @e_fr NVARCHAR (2000),
            @m NVARCHAR (2000), @message NVARCHAR (2000);
    DECLARE @q NVARCHAR (400) = NULLIF(LTRIM(RTRIM(@question)), N''), @id INT, @ref VARCHAR (20), @statut VARCHAR (20);
    DECLARE @v TABLE (id INT NOT NULL);
    SET @motif = NULLIF(LTRIM(RTRIM(@motif)), N'');
    SET @par = NULLIF(LTRIM(RTRIM(@par)), N'');
    BEGIN TRY
        IF @par IS NULL
            EXEC dbo.pr_e5_refuser 50870, N'Action refusée : l’auteur de l’action n’est pas transmis ; l’écran le transmet avec l’adresse de connexion de la personne qui clique.';
        EXEC sp_set_session_context N'par', @par;
        -- associe seul, juge ici avant toute ecriture : mandat ASSOCIE en cours sur une entite (du au plus tard
        -- aujourd'hui, au vide ou posterieur, regle de fn_peut_ecrire_referentiel) ; la garde de ref_question admet aussi
        -- le reviseur
        IF NOT EXISTS (SELECT 1 FROM dbo.role_mission r
                       WHERE r.connexion = @par AND r.role = 'ASSOCIE'
                         AND r.du <= CAST(SYSUTCDATETIME() AS DATE)
                         AND (r.au IS NULL OR r.au > CAST(SYSUTCDATETIME() AS DATE)))
            EXEC dbo.pr_e5_refuser 50875, N'Écart refusé : seul l’associé écarte une question de référence, et votre adresse de connexion ne porte aucun mandat d’associé en cours.';
        IF @q IS NULL
            EXEC dbo.pr_e5_refuser 50876, N'Écart refusé : choisissez la question dans la liste « Question ».';
        SELECT @id = id, @ref = reference, @statut = statut FROM dbo.ref_question WHERE reference = @q;
        IF @id IS NULL AND TRY_CAST(@q AS INT) IS NOT NULL
            SELECT @id = id, @ref = reference, @statut = statut FROM dbo.ref_question WHERE id = TRY_CAST(@q AS INT);
        IF @id IS NULL
        BEGIN
            SET @m = N'Écart refusé : la question « ' + @q + N' » n’est pas au référentiel des questions (liste « Question »).';
            EXEC dbo.pr_e5_refuser 50877, @m;
        END;
        IF @statut = 'ECARTEE'
        BEGIN
            SET @m = N'Écart refusé : la question ' + @ref + N' est déjà écartée.';
            EXEC dbo.pr_e5_refuser 50878, @m;
        END;
        -- le motif est facultatif, comme au n° 14 (script 323) ; un motif trop long est refuse
        IF LEN(@motif) > 600
        BEGIN
            SET @m = N'Écart refusé : le champ « Motif » compte ' + CAST(LEN(@motif) AS NVARCHAR (12))
                   + N' caractères, pour 600 au plus.';
            EXEC dbo.pr_e5_refuser 50880, @m;
        END;
        BEGIN TRANSACTION;
        UPDATE dbo.ref_question SET statut = 'ECARTEE'
        OUTPUT inserted.id INTO @v (id)
        WHERE id = @id AND statut <> 'ECARTEE';
        IF NOT EXISTS (SELECT 1 FROM @v)
        BEGIN
            SET @m = N'Écart refusé : la question ' + @ref + N' est déjà écartée.';
            EXEC dbo.pr_e5_refuser 50878, @m;
        END;
        SET @message = N'Question ' + @ref + N' écartée, statut « écartée ».'
                     + CASE WHEN @motif IS NULL THEN N'' ELSE N' Motif : « ' + @motif + N' ».' END;
        EXEC dbo.pr_poser_message_ecran @pour = @par, @message = @message, @genre = 'SUCCES', @entite = '-', @procedure_nom = @proc;
        COMMIT TRANSACTION;
        EXEC sp_set_session_context N'par', NULL;
        SELECT CAST('-' AS VARCHAR (20)) AS entite, @message AS message, @id AS question_id, @ref AS reference;
    END TRY
    BEGIN CATCH
        SELECT @e_num = ERROR_NUMBER(), @e_msg = ERROR_MESSAGE();
        IF @tc = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        BEGIN TRY EXEC sp_set_session_context N'par', NULL; END TRY BEGIN CATCH END CATCH;
        -- une violation de contrainte se dit en francais par le libelle de sa colonne, jamais par le nom de la contrainte
        SET @e_fr = dbo.fn_e5_traduire_erreur(@e_num, @e_msg);
        SET @m = ISNULL(@e_fr, @e_msg);
        -- appel direct : journal_refus (sauf la ligne deja inscrite par la garde) et message sous « - », apres le ROLLBACK
        EXEC dbo.pr_e5_conclure_refus @tc, @journal_avant, @proc, @par, '-', @m;
        IF @e_fr IS NOT NULL
            EXEC dbo.pr_e5_refuser 50889, @e_fr;
        THROW;
    END CATCH;
END;

GO

