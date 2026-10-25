-- ------------------------------------------------------------------ n° 15 : supprimer une ligne non employee
-- ecran 5, lot 1, script 323 (61_DEPLOIEMENT/generer_e5_323_procedures_de_tenue.py)
-- Raisons de [Blocage supprimer la ligne], dans l'ordre de la maquette : mode TEXTE, action_propre, droit,
-- actions_de_ligne 0, ligne employee, avec le renvoi a « Ecarter la ligne » (guillemets a espace fine insecable,
-- ECARTER_PLUTOT de la maquette, GUILLEMETS_202F de la mesure), ou, sur les 4 referentiels sans colonnes d'ecart, ou
-- « Ecarter la ligne » est gris, a ce qui met la ligne hors d'usage (PLUTOT_SANS_ECART, decision D-c).
CREATE   PROCEDURE dbo.pr_ecran_supprimer_ligne_referentiel
    @referentiel NVARCHAR (200) = NULL,
    @cle         NVARCHAR (400) = NULL,
    @par         NVARCHAR (400) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    -- @@TRANCOUNT lu seul, avant toute lecture de table : sous IMPLICIT_TRANSACTIONS (connexion sans autocommit d'une
    -- Data function), la 1re lecture ouvrirait la transaction de l'appelant avant la mesure
    DECLARE @tc INT = @@TRANCOUNT;
    DECLARE @journal_avant INT = ISNULL((SELECT MAX(id) FROM dbo.journal_refus), 0),
            @proc VARCHAR (60) = 'pr_ecran_supprimer_ligne_referentiel', @e_num INT, @e_msg NVARCHAR (2048), @e_fr NVARCHAR (2000),
            @e_journal NVARCHAR (2000), @e_entite VARCHAR (20), @m NVARCHAR (2000), @message NVARCHAR (2000);
    DECLARE @t VARCHAR (120), @lib NVARCHAR (160), @mode VARCHAR (5), @actions TINYINT, @propre NVARCHAR (60), @designation VARCHAR (128),
            @clause NVARCHAR (MAX), @affectation NVARCHAR (MAX), @k1 NVARCHAR (400), @k2 NVARCHAR (400), @canon NVARCHAR (400), @ligne NVARCHAR (400),
            @existe BIT, @emploi INT, @employee_par NVARCHAR (MAX), @sql NVARCHAR (MAX), @nb INT;
    SELECT @par = NULLIF(LTRIM(RTRIM(@par)), N''), @cle = NULLIF(LTRIM(RTRIM(@cle)), N'');
    BEGIN TRY
        IF @par IS NULL
            EXEC dbo.pr_e5_refuser 50830, N'Action refusée : l’auteur de l’action n’est pas transmis ; l’écran le transmet avec l’adresse de connexion de la personne qui clique.';
        EXEC sp_set_session_context N'par', @par;
        EXEC dbo.pr_e5_lire_referentiel @referentiel, @t OUTPUT, @lib OUTPUT, @mode OUTPUT, @actions OUTPUT, @propre OUTPUT, @designation OUTPUT;
        IF @mode = 'TEXTE'
        BEGIN
            SET @m = N'Suppression refusée sur « ' + @lib + N' » : fixé par un texte, non modifiable.';
            EXEC dbo.pr_e5_refuser 50832, @m;
        END;
        IF @propre IS NOT NULL
        BEGIN
            SET @m = N'Suppression refusée sur « ' + @lib + N' » : seuil propre au véhicule, posé par « Enregistrer le seuil du véhicule ».';
            EXEC dbo.pr_e5_refuser 50833, @m;
        END;
        IF dbo.fn_peut_ecrire_referentiel(@t, @par) = 0
        BEGIN
            SET @m = N'Suppression refusée sur « ' + @lib + N' » : aucun droit de modification.';
            EXEC dbo.pr_e5_refuser 50859, @m;
        END;
        IF @actions = 0
        BEGIN
            SET @m = N'Suppression refusée sur « ' + @lib + N' » : seule la valeur se modifie : les codes des paramètres sont fixés par l’outil.';
            EXEC dbo.pr_e5_refuser 50834, @m;
        END;
        IF @cle IS NULL
            EXEC dbo.pr_e5_refuser 50839, N'Choisissez la ligne dans la liste « Ligne ».';
        EXEC dbo.pr_e5_resoudre_cle @t, @cle, N'Ligne', N'@k', @clause OUTPUT, @affectation OUTPUT, @k1 OUTPUT, @k2 OUTPUT,
             @canon OUTPUT, @existe OUTPUT, @ligne OUTPUT;
        IF @existe = 0
        BEGIN
            SET @m = N'Suppression refusée : la ligne « ' + @cle + N' » n’est pas au référentiel « ' + @lib + N' ».';
            EXEC dbo.pr_e5_refuser 50842, @m;
        END;
        EXEC dbo.pr_e5_emploi @t, @clause, @k1, @k2, @canon, @cle, @emploi OUTPUT, @employee_par OUTPUT;
        IF @emploi > 0
        BEGIN
            SET @m = N'Suppression refusée : ligne employée par ' + @employee_par + N' ; ' + CASE @t
                WHEN 'ref_norme' THEN N'« Modifier la valeur » la marque hors d’usage sans la supprimer'
                WHEN 'ref_question' THEN N'« Écarter la question », à l’étape 3, la met hors d’usage sans la supprimer'
                WHEN 'ref_reference' THEN N'« Modifier la valeur » la marque hors d’usage sans la supprimer'
                WHEN 'ref_sujet_tenue' THEN N'un sujet qu’une question emploie reste dans la liste'
                ELSE N'« Écarter la ligne » la met hors d’usage sans la supprimer' END + N'.';
            EXEC dbo.pr_e5_refuser 50844, @m;
        END;
        BEGIN TRANSACTION;
        SET @sql = N'DELETE t FROM dbo.' + QUOTENAME(@t) + N' AS t WHERE ' + @clause + N'; SET @nb = @@ROWCOUNT;';
        EXEC sp_executesql @sql, N'@k1 NVARCHAR (400), @k2 NVARCHAR (400), @nb INT OUTPUT', @k1, @k2, @nb = @nb OUTPUT;
        SET @message = N'Ligne supprimée du référentiel « ' + @lib + N' » : « ' + @ligne + N' ».';
        EXEC dbo.pr_poser_message_ecran @pour = @par, @message = @message, @genre = 'SUCCES', @entite = '-', @procedure_nom = @proc;
        COMMIT TRANSACTION;
        EXEC sp_set_session_context N'par', NULL;
        SELECT CAST('-' AS VARCHAR (20)) AS entite, @message AS message;
    END TRY
    BEGIN CATCH
        SELECT @e_num = ERROR_NUMBER(), @e_msg = ERROR_MESSAGE();
        IF @tc = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        BEGIN TRY EXEC sp_set_session_context N'par', NULL; END TRY BEGIN CATCH END CATCH;
        SET @e_fr = dbo.fn_e5_traduire_erreur(@e_num, @e_msg);
        -- un refus de garde (ROLLBACK, inscription, THROW, objet n° 17) recu sous 266 ou 3609 : son texte francais est
        -- la ligne qu'un declencheur a inscrite pour @par depuis l'entree
        IF @e_fr IS NULL AND @e_num IN (266, 3609) AND @par IS NOT NULL
            SELECT TOP (1) @e_fr = j.message FROM dbo.journal_refus j
            WHERE j.id > @journal_avant AND j.procedure_nom LIKE 'tr[_]%' AND j.refuse_pour = LEFT(@par, 200)
            ORDER BY j.id DESC;
        SET @e_journal = ISNULL(@e_fr, @e_msg);
        SET @e_entite = '-';
        EXEC dbo.pr_e5_conclure_refus @tc, @journal_avant, @proc, @par, @e_entite, @e_journal;
        IF @e_fr IS NOT NULL EXEC dbo.pr_e5_refuser 50868, @e_fr;
        THROW;
    END CATCH;
END;

GO

