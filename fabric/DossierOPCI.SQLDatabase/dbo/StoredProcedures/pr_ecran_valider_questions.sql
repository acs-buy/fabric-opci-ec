-- 4. Les procedures de l'etape 3 et de la Revision
-- ecran 5, lot 1, script 324 (61_DEPLOIEMENT/generer_e5_324_questions.py) : genere, ne pas modifier a la main.
-- Objet n° 32 : « Valider les questions du cycle ». Passe a VALIDEE les questions A_AUDITER (« à valider ») du cycle ou
-- de la phase, recu par son code ou par son nom d'usage (segment « Cycle ou phase »). Refus en francais, avant toute
-- ecriture : @par vide, cycle ou phase vide, inconnu ou de code commun a un cycle et a une phase, puis les 2 etats de
-- blocage de [Etat de la validation] dans l'ordre ou la mesure les nomme, « aucune question a valider » (50874) et
-- « reserve a l'associe » (50875, aucun mandat ASSOCIE en cours sur @par ; decision D-d de la session base, B2).
-- Les declencheurs le jugent encore a l'ecriture : tr_ref_question_garde, en tete (50074), et tr_question_statut (50076).
-- Message de reussite sous « - », sans action jointe, au caractere pres sur la maquette (fn_e5_message_validation).
CREATE   PROCEDURE dbo.pr_ecran_valider_questions
    @cycle_ou_phase NVARCHAR (400) = NULL,
    @par            NVARCHAR (400) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @tc INT = @@TRANCOUNT, @journal_avant INT = ISNULL((SELECT MAX(id) FROM dbo.journal_refus), 0),
            @proc VARCHAR (60) = 'pr_ecran_valider_questions', @e_num INT, @e_msg NVARCHAR (2048), @e_fr NVARCHAR (2000),
            @m NVARCHAR (2000), @message NVARCHAR (2000);
    DECLARE @cp NVARCHAR (400) = NULLIF(LTRIM(RTRIM(@cycle_ou_phase)), N''), @code VARCHAR (10), @genre VARCHAR (5),
            @nom NVARCHAR (400), @n INT;
    DECLARE @v TABLE (id INT NOT NULL);
    SET @par = NULLIF(LTRIM(RTRIM(@par)), N'');
    BEGIN TRY
        IF @par IS NULL
            EXEC dbo.pr_e5_refuser 50870, N'Action refusée : l’auteur de l’action n’est pas transmis ; l’écran le transmet avec l’adresse de connexion de la personne qui clique.';
        EXEC sp_set_session_context N'par', @par;
        IF @cp IS NULL
            EXEC dbo.pr_e5_refuser 50871, N'Validation refusée : choisissez le cycle ou la phase dans la liste « Cycle ou phase ».';
        IF (SELECT COUNT(*) FROM dbo.v_ecran_cycle_ou_phase cp WHERE cp.code = @cp) > 1
        BEGIN
            SET @m = N'Validation refusée : ' + N'« ' + @cp + N' » est à la fois le code d’un cycle et celui d’une phase des questions '
                   + N'de référence ; changez l’un des 2 codes dans son référentiel.';
            EXEC dbo.pr_e5_refuser 50887, @m;
        END;
        SELECT TOP (1) @code = cp.code, @genre = cp.genre, @nom = cp.nom_usage
        FROM dbo.v_ecran_cycle_ou_phase cp
        WHERE cp.code = @cp OR cp.nom_usage = @cp
        ORDER BY CASE WHEN cp.code = @cp THEN 0 ELSE 1 END, cp.ordre;
        IF @code IS NULL
        BEGIN
            SET @m = N'Validation refusée : ' + N'« ' + @cp + N' » n’est ni un cycle ni une phase des questions de référence (liste « Cycle ou phase »).';
            EXEC dbo.pr_e5_refuser 50872, @m;
        END;
        IF NOT EXISTS (SELECT 1 FROM dbo.ref_question q WHERE q.statut = 'A_AUDITER'
                       AND ((@genre = 'CYCLE' AND q.cycle = @code) OR (@genre = 'PHASE' AND q.phase = @code)))
        BEGIN
            SET @m = N'Validation refusée : aucune question à valider '
                   + CASE @genre WHEN 'CYCLE' THEN N'dans le cycle ' ELSE N'dans la phase ' END + @nom + N'.';
            EXEC dbo.pr_e5_refuser 50874, @m;
        END;
        -- etat « reserve a l'associe » de [Etat de la validation] ([Associe du cabinet connecte] vide), juge ici avant
        -- toute ecriture (decision D-d de la session base, B2), apres « aucune question a valider », dans l'ordre ou la
        -- mesure nomme ses etats : mandat ASSOCIE en cours sur une entite, regle de date de fn_peut_ecrire_referentiel ;
        -- tr_ref_question_garde (50074) et tr_question_statut (50076) le jugent encore a l'ecriture
        IF NOT EXISTS (SELECT 1 FROM dbo.role_mission r
                       WHERE r.connexion = @par AND r.role = 'ASSOCIE'
                         AND r.du <= CAST(SYSUTCDATETIME() AS DATE)
                         AND (r.au IS NULL OR r.au > CAST(SYSUTCDATETIME() AS DATE)))
            EXEC dbo.pr_e5_refuser 50875, N'Validation refusée : réservé à l’associé. Seul l’associé valide une question de référence, et votre adresse de connexion ne porte aucun mandat d’associé en cours.';
        BEGIN TRANSACTION;
        UPDATE dbo.ref_question SET statut = 'VALIDEE'
        OUTPUT inserted.id INTO @v (id)
        WHERE statut = 'A_AUDITER' AND ((@genre = 'CYCLE' AND cycle = @code) OR (@genre = 'PHASE' AND phase = @code));
        SET @n = (SELECT COUNT(*) FROM @v);
        IF @n = 0
        BEGIN
            SET @m = N'Validation refusée : aucune question à valider '
                   + CASE @genre WHEN 'CYCLE' THEN N'dans le cycle ' ELSE N'dans la phase ' END + @nom + N'.';
            EXEC dbo.pr_e5_refuser 50874, @m;
        END;
        SET @message = dbo.fn_e5_message_validation(@nom, @genre, @n);
        EXEC dbo.pr_poser_message_ecran @pour = @par, @message = @message, @genre = 'SUCCES', @entite = '-', @procedure_nom = @proc;
        COMMIT TRANSACTION;
        EXEC sp_set_session_context N'par', NULL;
        SELECT CAST('-' AS VARCHAR (20)) AS entite, @message AS message, @code AS cycle_ou_phase, @n AS questions_validees;
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

