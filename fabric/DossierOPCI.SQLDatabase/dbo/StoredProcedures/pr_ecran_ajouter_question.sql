-- ecran 5, lot 1, script 324 (61_DEPLOIEMENT/generer_e5_324_questions.py) : genere, ne pas modifier a la main.
-- Objet n° 203 (et non 202 : decision D-h de la session base) : « Ajouter une question » de la Revision (ec02, etape 2,
-- bande des cycles). Les regles du n° 35 sans sujet ni niveau (niveau_programme vide). Le droit est celui de
-- tr_ref_question_garde, associe ou reviseur (ref_question tenue par REVISEUR au registre), juge ici avant toute
-- ecriture par fn_peut_ecrire_referentiel sur @par (50888 ; decision D-d : l'etat qui grise le bouton, [Teneur des
-- questions connecte] vide ; arbitrage de la session base du 21/10/2026, piece
-- 65_JOURNAL/preuves_ecran_5/decisions_session_base_lot1_20261021.md, ligne D-d, commit eacaaa99), puis par la garde
-- a l'ecriture (50074). Le cycle se recoit par son nom d'usage
-- (ref_cycle[Cycle] du modele) ou par son code ; une phase est admise. Date d'effet en_vigueur_depuis : la date de
-- l'ajout (UTC), comme au n° 35. Refus en francais : @par vide, droit, cycle ou phase vide, inconnu, ecarte ou de code
-- commun a un cycle et a une phase, enonce vide ou de plus de 400 caracteres. Message sous « - », que [Message de
-- la revision] lit sur ec02.
CREATE   PROCEDURE dbo.pr_ecran_ajouter_question
    @cycle_ou_phase NVARCHAR (400) = NULL,
    @enonce         NVARCHAR (MAX) = NULL,
    @par            NVARCHAR (400) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @tc INT = @@TRANCOUNT, @journal_avant INT = ISNULL((SELECT MAX(id) FROM dbo.journal_refus), 0),
            @proc VARCHAR (60) = 'pr_ecran_ajouter_question', @e_num INT, @e_msg NVARCHAR (2048), @e_fr NVARCHAR (2000),
            @m NVARCHAR (2000), @message NVARCHAR (2000);
    DECLARE @cp NVARCHAR (400) = NULLIF(LTRIM(RTRIM(@cycle_ou_phase)), N''), @code VARCHAR (10), @genre VARCHAR (5),
            @nom NVARCHAR (400), @ecartee DATE, @num INT, @ordre INT, @ref VARCHAR (20);
    DECLARE @v TABLE (id INT NOT NULL);
    SET @enonce = NULLIF(LTRIM(RTRIM(@enonce)), N'');
    SET @par = NULLIF(LTRIM(RTRIM(@par)), N'');
    BEGIN TRY
        IF @par IS NULL
            EXEC dbo.pr_e5_refuser 50870, N'Action refusée : l’auteur de l’action n’est pas transmis ; l’écran le transmet avec l’adresse de connexion de la personne qui clique.';
        EXEC sp_set_session_context N'par', @par;
        -- droit, juge ici avant toute ecriture (decision D-d de la session base) : [Teneur des questions connecte] vide
        -- grise le bouton de la Revision ; la regle est celle de tr_ref_question_garde, fn_peut_ecrire_referentiel sur
        -- @par (ref_question tenue par REVISEUR au registre : associe ou reviseur, mandat en cours), qui la rejoue en 50074
        IF dbo.fn_peut_ecrire_referentiel('ref_question', @par) = 0
            EXEC dbo.pr_e5_refuser 50888, N'Ajout refusé : seuls l’associé et le réviseur ajoutent une question de référence, et votre adresse de connexion ne porte aucun mandat d’associé ni de réviseur en cours.';
        IF @cp IS NULL
            EXEC dbo.pr_e5_refuser 50871, N'Ajout refusé : choisissez le cycle dans la bande des cycles.';
        IF (SELECT COUNT(*) FROM dbo.v_ecran_cycle_ou_phase cp WHERE cp.code = @cp) > 1
        BEGIN
            SET @m = N'Ajout refusé : ' + N'« ' + @cp + N' » est à la fois le code d’un cycle et celui d’une phase des questions '
                   + N'de référence ; changez l’un des 2 codes dans son référentiel.';
            EXEC dbo.pr_e5_refuser 50887, @m;
        END;
        SELECT TOP (1) @code = cp.code, @genre = cp.genre, @nom = cp.nom_usage
        FROM dbo.v_ecran_cycle_ou_phase cp
        WHERE cp.code = @cp OR cp.nom_usage = @cp
        ORDER BY CASE WHEN cp.code = @cp THEN 0 ELSE 1 END, cp.ordre;
        IF @code IS NULL
        BEGIN
            SET @m = N'Ajout refusé : ' + N'« ' + @cp + N' » n’est ni un cycle ni une phase des questions de référence (liste « Cycle ou phase »).';
            EXEC dbo.pr_e5_refuser 50872, @m;
        END;
        -- un cycle ou une phase ecarte (ecartee_le posee, objet n° 10) ne recoit plus de question (§ 1.3)
        SET @ecartee = CASE @genre WHEN 'CYCLE' THEN (SELECT c.ecartee_le FROM dbo.ref_cycle c WHERE c.code = @code)
                                   ELSE (SELECT p.ecartee_le FROM dbo.ref_phase p WHERE p.code = @code) END;
        IF @ecartee IS NOT NULL
        BEGIN
            SET @m = N'Ajout refusé : ' + CASE @genre WHEN 'CYCLE' THEN N'le cycle ' + @nom + N' est écarté'
                                                     ELSE N'la phase ' + @nom + N' est écartée' END
                   + N' depuis le ' + CONVERT(NVARCHAR (10), @ecartee, 103) + N' ; une question ne s’y ajoute plus.';
            EXEC dbo.pr_e5_refuser 50873, @m;
        END;
        IF @enonce IS NULL
            EXEC dbo.pr_e5_refuser 50885, N'Ajout refusé : saisissez l’énoncé dans le champ « Énoncé de la question ».';
        IF LEN(@enonce) > 400
        BEGIN
            SET @m = N'Ajout refusé : le champ « Énoncé de la question » compte ' + CAST(LEN(@enonce) AS NVARCHAR (12))
                   + N' caractères, pour 400 au plus.';
            EXEC dbo.pr_e5_refuser 50886, @m;
        END;
        BEGIN TRANSACTION;
        -- reference CODE-NN a la suite des references de cette forme, toutes questions confondues (uq_ref_question_reference),
        -- ordre au plus grand du cycle ou de la phase plus 1 ; lus sous verrou jusqu'a la fin de la transaction
        SELECT @num = ISNULL(MAX(TRY_CAST(SUBSTRING(q.reference, LEN(@code) + 2, 20) AS INT)), 0) + 1
        FROM dbo.ref_question q WITH (UPDLOCK, HOLDLOCK)
        WHERE LEFT(q.reference, LEN(@code) + 1) = @code + '-'
          AND LEN(q.reference) > LEN(@code) + 1
          AND SUBSTRING(q.reference, LEN(@code) + 2, 20) NOT LIKE '%[^0-9]%';
        SET @ref = @code + '-' + CASE WHEN @num < 10 THEN '0' ELSE '' END + CAST(@num AS VARCHAR (10));
        SELECT @ordre = ISNULL(MAX(q.ordre), 0) + 1
        FROM dbo.ref_question q WITH (UPDLOCK, HOLDLOCK)
        WHERE (@genre = 'CYCLE' AND q.cycle = @code) OR (@genre = 'PHASE' AND q.phase = @code);
        -- obligatoire et statut prennent leur defaut (1, A_AUDITER) : la question nait « à valider » ; la ligne inseree
        -- recoit modifie_par = @par et modifie_le de la procedure, les horodatages etant AFTER UPDATE (§ 1.3) ; sa date
        -- d'effet est la date de l'ajout (UTC), regle O25 du script 105 : en_vigueur_depuis, date NULL sans defaut, laissee
        -- vide, ferait compter la question par le controle C49 (v_controle_sans_date_effet, 0 ligne attendue)
        INSERT INTO dbo.ref_question (reference, cycle, phase, enonce, type_reponse, applicabilite, ordre,
                                      niveau_programme, en_vigueur_depuis, modifie_par, modifie_le)
        OUTPUT inserted.id INTO @v (id)
        VALUES (@ref, CASE WHEN @genre = 'CYCLE' THEN @code END, CASE WHEN @genre = 'PHASE' THEN @code END, @enonce,
                'OUI_NON_NA', 'LES_DEUX', @ordre, NULL, CAST(SYSUTCDATETIME() AS DATE), @par, SYSUTCDATETIME());
        SET @message = N'Question ' + @ref + CASE @genre WHEN 'CYCLE' THEN N' ajoutée au cycle ' ELSE N' ajoutée à la phase ' END
                     + @nom + N', statut « à valider ».';
        EXEC dbo.pr_poser_message_ecran @pour = @par, @message = @message, @genre = 'SUCCES', @entite = '-', @procedure_nom = @proc;
        COMMIT TRANSACTION;
        EXEC sp_set_session_context N'par', NULL;
        SELECT CAST('-' AS VARCHAR (20)) AS entite, @message AS message, (SELECT TOP (1) id FROM @v) AS question_id,
               @ref AS reference, @code AS cycle_ou_phase;
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

